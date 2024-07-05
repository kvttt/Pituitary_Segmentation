Pituitary Segmentation
======================

Atlas-based segmentation of the pituitary in MR images.

New Features
------------
- Now supports multi-atlas segmentation. Check out `multi_atlas_example.py` for more details.
- Also provides a command-line tool for automatic pituitary segmentation without dependency on Python or ANTsPy.
- Python tools
  - For segmentation using a single atlas, use `main.py`.
  - For an example of how to leverage multiple atlases to give more robust segmentation, see `multi_atlas_example.py`.
- Bash tool (recommended)
  - For the command-line tool written bash that supprots multiple atlases, use `pituitary_segmentation.sh`.

Bash tool
---------

### Dependencies
- [ANTs](https://github.com/ANTsX/ANTs)

Check out ANTs' [official repository](https://github.com/ANTsX/ANTs) for instructions on how to install ANTs.

### Usage
```
Atlas-based pituitary segmentation using ANTs.

Usage: ./pituitary_segmentation.sh <input> <output> [-t transform] [-c] [-n] [-h]

Options:
  <input>         Input image filename.
  <output>        Output image filename.
  -t transform    Type of transform to use in registration. Default: Affine.
  -c cutoff       Cutoff value for the mask. Default: 5.
  -n              Apply N4 bias correction to the input image.
  -h              Display this help message.
```

Python tool
-----------

### Dependencies
- [ANTsPy](https://github.com/ANTsX/ANTsPy)

To install ANTsPy, run:
```bash
pip install antspyx
```

### Usage
```bash
python main.py --in <input_image> --out <output_image>
```

### Options
- `--transform`: Specify the type of transform to use for ANTs registration. Default is `Affine`.
For other options, see [ANTsPy documentation](https://antspy.readthedocs.io/en/latest/registration.html).
- `--n4`: Optionally apply N4 bias correction to the input image.

Acknowledgements
----------------
- MNI152 2009a Nonlinear Asymmetric atlas taken from [here](https://www.bic.mni.mcgill.ca/ServicesAtlases/ICBM152NLin2009).
- Pituitary mask annotated by [expert](https://github.com/weijunhuashan).
