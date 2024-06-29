Pituitary Segmentation
======================

Atlas-based segmentation of the pituitary in MR images.

Dependencies
------------
- [ANTsPy](https://github.com/ANTsX/ANTsPy)

To install ANTsPy, run:
```bash
pip install antspyx
```

Usage
-----
```bash
python main.py --in <input_image> --out <output_image>
```

Options
-------
- `--transform`: Specify the type of transform to use for ANTs registration. Default is `Affine`.
For other options, see [ANTsPy documentation](https://antspy.readthedocs.io/en/latest/registration.html).
- `--n4`: Optionally apply N4 bias correction to the input image.

Acknowledgements
----------------
- MNI152 2009a Nonlinear Asymmetric atlas taken from [here](https://www.bic.mni.mcgill.ca/ServicesAtlases/ICBM152NLin2009).
- Pituitary mask annotated by [expert](https://github.com/weijunhuashan).