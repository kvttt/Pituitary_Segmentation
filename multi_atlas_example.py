import ants

atlas_list = ["atlas_001.nii.gz", "atlas_002.nii.gz", "atlas_003.nii.gz", "atlas_004.nii.gz", "atlas_005.nii.gz",
              "atlas_006.nii.gz", "atlas_007.nii.gz", "atlas_008.nii.gz", "atlas_009.nii.gz", "atlas_010.nii.gz"]
mask_list = ["mask_001.nii.gz", "mask_002.nii.gz", "mask_003.nii.gz", "mask_004.nii.gz", "mask_005.nii.gz",
             "mask_006.nii.gz", "mask_007.nii.gz", "mask_008.nii.gz", "mask_009.nii.gz", "mask_010.nii.gz"]


def main(fn_in, fn_out, type_of_transform="Affine", n4=False, threshold=5):
    global out_image
    print(f'Reading image from: {fn_in}')
    image = ants.image_read(fn_in)
    print('Done')

    if n4:
        print('Performing N4 bias field correction')
        image = ants.n4_bias_field_correction(image)
        print('Done')

    for i in range(10):
        print("=" * 25)
        print(f'Processing atlas {i + 1}')
        atlas = ants.image_read(atlas_list[i])
        mask = ants.image_read(mask_list[i])

        print('Registering atlas to image')
        fwdtransforms = ants.registration(fixed=image, moving=atlas, type_of_transform=type_of_transform)[
            "fwdtransforms"]
        print('Done')

        print('Applying transform to mask')
        warped_mask = ants.apply_transforms(fixed=image, moving=mask, transformlist=fwdtransforms,
                                            interpolator="nearestNeighbor")
        print('Done')
        # if first iteration, set out_image to warped_mask, else add warped_mask to out_image
        out_image = warped_mask if i == 0 else out_image + warped_mask

    print(f'Applying threshold of {threshold}')
    # cut off values below threshold 5, and perform no cleanup (cleanup=0)
    out_image = ants.get_mask(out_image, low_thresh=threshold, cleanup=0)
    print('Done')

    print(f'Writing warped mask to: {fn_out}')
    ants.image_write(out_image, fn_out)
    print('Done')


if __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument("--in", dest="fn_in", type=str, required=True, help="Input image filename")
    parser.add_argument("--out", dest="fn_out", type=str, required=True, help="Output image filename")
    parser.add_argument("--transform", dest="type_of_transform", type=str, default="Affine",
                        help="Type of transform, e.g., 'Affine', 'SyN'")
    parser.add_argument("--n4", dest="n4", action="store_true", help="Optionally perform N4 bias field correction")
    args = parser.parse_args()

    main(args.fn_in, args.fn_out, args.type_of_transform, args.n4)
