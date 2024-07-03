#!/usr/bin/bash
# pituitary_segmentation.sh - command line tool for pituitary segmentation based on ANTs

args=()
transform="Affine"
cutoff=5
n4=false

atlases=("atlas_001.nii.gz" "atlas_002.nii.gz" "atlas_003.nii.gz" "atlas_004.nii.gz" "atlas_005.nii.gz" "atlas_006.nii.gz" "atlas_007.nii.gz" "atlas_008.nii.gz" "atlas_009.nii.gz" "atlas_010.nii.gz")
masks=("mask_001.nii.gz" "mask_002.nii.gz" "mask_003.nii.gz" "mask_004.nii.gz" "mask_005.nii.gz" "mask_006.nii.gz" "mask_007.nii.gz" "mask_008.nii.gz" "mask_009.nii.gz" "mask_010.nii.gz")

usage() {
    echo
    echo "Atlas-based pituitary segmentation using ANTs."
    echo
    echo "Usage: $0 <input> <output> [-t transform] [-c] [-n] [-h]"
    echo
    echo "Options:"
    echo "  <input>         Input image filename."
    echo "  <output>        Output image filename."
    echo "  -t transform    Type of transform to use in registration. Default: Affine."
    echo "  -c cutoff       Cutoff value for the mask. Default: 5."
    echo "  -n              Apply N4 bias correction to the input image."
    echo "  -h              Display this help message."
    echo
    exit 0
}

while [ $OPTIND -le "$#" ]
do
    if getopts t:c:nh option
    then
        case $option
        in
            t) transform="$OPTARG";;
            c) cutoff="$OPTARG";;
            n) n4=true;;
            h) usage;;
        esac
    else
        args+=("${!OPTIND}")
        ((OPTIND++))
    fi
done

echo "Transform: $transform"
echo "N4: $n4"
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
    antsRegistrationSyN.sh -d 3 -f "${input}" -m "${atlases[$i]}" -o "${input%.nii.gz}_atlas_${i}_"
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
