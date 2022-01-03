# mcf2html

An XSLT script to convert Cewe's MCF files to HTML, so that a browser can be used to produce a decent preview PDF.  (Cewe also produces the software for Amazon, dm, Müller, Rossmann, Budni, Edeka, Saturn, Kaufland, real, Otto and many more.)

## Prerequisites

* A browser.  The process_mcf.sh script assumes Google Chrome.
* An XSLT 2.0 processor.  The process_mcf.sh assumes Saxon (package libsaxonb-java on Debian).

## Usage

```
./process_mcf.sh /path/to/your.mcf
```

The script will process the MCF file to HTML, then start Chrome.  All images in the calendar or photobook will initially appear as broken image links, but will fill as the browser processes them.  Once processing is done, the print dialog will open.

## Weaknesses

* I made this to process *my* calendars and photobooks.  It doesn't support Z order, is missing support for large numbers of calendarium types and doubtless 18 other features.  Complete support should be possible, but what's implemented is just what I needed.

* The size of the PDF is dependent on the pixel dimensions of the images in the browser.  This is, in turn, dependent on the display resolution and the display CSS.

## Disclaimer

I am not associated in any way with Cewe nor any of their resellers.  Cewe don't provide a PDF preview function in their software.  I assume this is because they don't want people to use their editing software, then make a PDF and print things themselves.  Please don't do that using this script either.

## Author

* [Jon Bright](https://github.com/Jon-Bright)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.
