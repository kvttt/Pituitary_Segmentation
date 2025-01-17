#!/bin/bash
# pituitary_segmentation.sh - command line tool for pituitary segmentation based on ANTs

args=()
transform="Affine"
cutoff=5
n4=false
threads=1

atlases=("atlas_001.nii.gz" "atlas_002.nii.gz" "atlas_003.nii.gz" "atlas_004.nii.gz" "atlas_005.nii.gz" "atlas_006.nii.gz" "atlas_007.nii.gz" "atlas_008.nii.gz" "atlas_009.nii.gz" "atlas_010.nii.gz")
masks=("mask_001.nii.gz" "mask_002.nii.gz" "mask_003.nii.gz" "mask_004.nii.gz" "mask_005.nii.gz" "mask_006.nii.gz" "mask_007.nii.gz" "mask_008.nii.gz" "mask_009.nii.gz" "mask_010.nii.gz")

usage() {
    echo
    echo "Atlas-based pituitary segmentation using ANTs."
    echo
    echo "Usage: $0 <input> <output> [-t transform] [-c cutoff] [-m threads] [-n] [-h]"
    echo
    echo "Options:"
    echo "  <input>         Input image filename."
    echo "  <output>        Output image filename."
    echo "  -t transform    Type of transform to use in registration. Default: Affine. Currently supported: Affine, SyN, SyNQuick."
    echo "  -c cutoff       Cutoff value for the mask. Default: 5."
    echo "  -m threads      Number of threads to use. Default: 1. Increase this value to speed up the registration process."
    echo "  -n              Apply N4 bias correction to the input image."
    echo "  -h              Display this help message."
    echo
    exit 0
}

if [ "$#" -lt 2 ]
then
    usage
fi

while [ $OPTIND -le "$#" ]
do
    if getopts t:c:m:nh option
    then
        case $option
        in
            t) transform="$OPTARG";;
            c) cutoff="$OPTARG";;
            m) threads="$OPTARG";;
            n) n4=true;;
            h) usage;;
        esac
    else
        args+=("${!OPTIND}")
        ((OPTIND++))
    fi
done

if [ "$transform" != "Affine" ] && [ "$transform" != "SyN" ] && [ "$transform" != "SyNQuick" ]
then
    echo "Unsupported transform type $transform. Exiting..."
    exit 1
fi

if [ "$cutoff" -lt 0 ]
then
    echo "Cutoff value must be non-negative. Exiting..."
    exit 1
elif [ "$cutoff" -eq 0 ]
then
    echo "Cutoff value of 0 will result in an empty mask. Exiting..."
    exit 1
elif [ "$cutoff" -gt 10 ]
then
    echo "Cutoff value must be less than or equal to 10. Exiting..."
    exit 1
fi

if [ "$threads" -lt 1 ]
then
    echo "Number of threads must be at least 1. Exiting..."
    exit 1
fi

echo "Transform: $transform"
echo "N4: $n4"
echo "Cutoff: $cutoff"
echo "Threads: $threads"
echo "Input filename: ${args[0]}"
echo "Output filename: ${args[1]}"

# optional N4 bias correction
if [ "$n4" = true ]
then
    echo "Applying N4 bias correction to the input image..."
    N4BiasFieldCorrection -d 3 -i "${args[0]}" -o "${args[0]%.nii.gz}_n4.nii.gz"
    echo "N4 bias corrected image saved as ${args[0]%.nii.gz}_n4.nii.gz."
    input="${args[0]%.nii.gz}_n4.nii.gz"
else
    input="${args[0]}"
fi

# register each atlas to the input image and apply transformation to the corresponding mask
for i in {0..9}
do
    echo "Registering atlas ${atlases[$i]} to the input image..."
    
    if [ "$transform" = "Affine" ]
    then
        echo "Performing affine registration..."
        antsRegistrationSyN.sh -d 3 -f "${input}" -m "${atlases[$i]}" -o "${input%.nii.gz}_atlas_${i}_" -t a -n "$threads"
    elif [ "$transform" = "SyN" ]
    then
        echo "Performing deformable registration (SyN)..."
        antsRegistrationSyN.sh -d 3 -f "${input}" -m "${atlases[$i]}" -o "${input%.nii.gz}_atlas_${i}_" -t s -n "$threads"
    elif [ "$transform" = "SyNQuick" ]
    then
        echo "Performing deformable registration (SyNQuick)..."
        antsRegistrationSyNQuick.sh -d 3 -f "${input}" -m "${atlases[$i]}" -o "${input%.nii.gz}_atlas_${i}_" -t s -n "$threads"
    else
        echo "Unsupported transform type. Exiting..."
        exit 1
    fi

    echo "Applying transformation to the mask ${masks[$i]}..."
    antsApplyTransforms -d 3 -i "${masks[$i]}" -r "${input}" -o "${input%.nii.gz}_mask_${i}.nii.gz" -n NearestNeighbor -t "${input%.nii.gz}_atlas_${i}_0GenericAffine.mat"
done

# combine the transformed masks
echo "Combining the transformed masks..."
ImageMath 3 "${args[1]}" + "${input%.nii.gz}_mask_0.nii.gz" "${input%.nii.gz}_mask_1.nii.gz" "${input%.nii.gz}_mask_2.nii.gz" "${input%.nii.gz}_mask_3.nii.gz" "${input%.nii.gz}_mask_4.nii.gz" "${input%.nii.gz}_mask_5.nii.gz" "${input%.nii.gz}_mask_6.nii.gz" "${input%.nii.gz}_mask_7.nii.gz" "${input%.nii.gz}_mask_8.nii.gz" "${input%.nii.gz}_mask_9.nii.gz"
echo "Segmentation saved as ${args[1]}."

# apply cutoff
echo "Applying cutoff value of $cutoff..."
ThresholdImage 3 "${args[1]}" "${args[1]}" "$cutoff" 10000
echo "Final segmentation saved as ${args[1]}."

# clean up
echo "Cleaning up..."
rm "${input%.nii.gz}_mask_"*
rm "${input%.nii.gz}_atlas_"*
echo "Done."

exit 0
