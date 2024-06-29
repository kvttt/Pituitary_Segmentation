import ants


def main(fn_in, fn_out, type_of_transform="Affine", n4=False):
    print(f'Reading image from: {fn_in}')
    image = ants.image_read(fn_in)
    print('Done')

    if n4:
        print('Performing N4 bias field correction')
        image = ants.n4_bias_field_correction(image)
        print('Done')

    print('Reading atlas and mask')
    atlas = ants.image_read("./mni_icbm152_t1_tal_nlin_asym_09a.nii")
    mask = ants.image_read("./pituitary_mask_2009a.nii.gz")
    print('Done')

    print('Registering atlas to image')
    fwdtransforms = ants.registration(fixed=image, moving=atlas, type_of_transform=type_of_transform)["fwdtransforms"]
    print('Done')

    print('Applying transform to mask')
    warped_mask = ants.apply_transforms(fixed=image, moving=mask, transformlist=fwdtransforms,
                                        interpolator="nearestNeighbor")
    print('Done')

    print(f'Writing warped mask to: {fn_out}')
    ants.image_write(warped_mask, fn_out)
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
