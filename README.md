PDF-Grammar-Simple
==================

PDF::Grammar::PDF is an experimental perl6 Grammar for parsing
non-linearized PDF documents.

This is a proof of concept to see if a grammer can be reasonbly constructed
to tokenize real-world PDF documents. It has so far been tested against a
limited sample of PDF documents. Further more it has so far been built and
tested against Rakudo Star 2012-11.

If this gammar survives at all; the tokens and capturing rules that
comprise it will most likely change significantly.

Works best with PDFs up to 1.5. May work for high versions if they haven't
been linearized (Web Optimized).

The only dependency is Rakudo Star. It runs on `perl6`. `ufo` is also to
locally create the Makefile. To run the tests, after building rakudo star
(https://github.com/rakudo/rakudo - don't forget the final `make install`):

    % git co git@github.com:dwarring/PDF-Grammar-Simple.git
    % cd /PDF-Grammar-Simple
    % # to get perl6 and ufo
    % export PATH=~/src/rakudo-star-2012.11/install/bin:$PATH
    % ufo # Build Makefile
    % make
    % make test
    %
    % # ... alternatively...
    % PERL6LIB=lib prove -v -e 'perl6' t