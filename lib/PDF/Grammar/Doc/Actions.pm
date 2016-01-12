use v6;

use PDF::Grammar::Actions;

# rules for constructing PDF::Grammar::PDF AST

class PDF::Grammar::Doc::Actions
    is PDF::Grammar::Actions {
 
    has Bool $.get-offsets is rw = False; #| return ind-obj byte offsets in AST

    method TOP($/) { make $<pdf>.ast.value }

    method pdf($/) {
        my $header = $<header>.ast;
	my $body = [ $<body>>>.ast.map({ .value }) ];
        make 'pdf' => {
	    :$header,
	    :$body,
        }
    }
    method doc-type($/) {
        make $/.uc
    }

    method header($/)    {
        my $type = $<doc-type>.ast;
        my $version = $<version>.Rat;
        make { :$type, :$version }
    }

    method postamble($/) {
        my %postamble;
        %postamble<startxref> = $<byte-offset>.ast.value
            if $<byte-offset>;
        %postamble<trailer> = $<trailer>.ast.value
            if $<trailer>;

        make %postamble;
    }

    method trailer($/)   {
	make (:trailer($<dict>.ast))
    }

    method startxref($/)   {
	make (:startxref($<byte-offset>.ast.value))
    }

    method ind-ref($/) {
        my $obj-num = $<obj-num>.ast.value;
        my $gen-num = $<gen-num>.ast.value;
        my $ind-ref = [ $obj-num, $gen-num ];
        make (:$ind-ref);
    }

    method ind-obj($/) {
        my $obj-num = $<obj-num>.ast.value;
        my $gen-num = $<gen-num>.ast.value;
        my $ind-obj = [ $obj-num, $gen-num, $<object>.ast ];
        $ind-obj.push: $/.from
            if self.get-offsets;
        make (:$ind-obj)
    }

    method object:sym<ind-ref>($/)  { make $<ind-ref>.ast }

    method object:sym<dict>($/) {

        if ($<stream>) {
            # <dict> is a just a header the following <stream>
            my %stream = $<dict>.ast.kv;
	    %stream<encoded> = $<stream>.ast;
            make (:%stream)
        }
        else {
            # simple stand-alone <dict>
            make $<dict>.ast;
        }
    }

    method body($/) {
        my %body = flat (:objects[ $<ind-obj>>>.ast ],
                    ($<startxref> ?? $<startxref>.ast !! () ),
                    ($<index>.defined ?? @( $<index>.ast ) !! () ),
            );

        make (:%body);
    }

    method index($/) {
        my %index = flat ($<xref>.defined ?? $<xref>.ast !! (),
                     $<trailer>.ast);
        make %index;
    }

    method xref($/) {
	my $sections = [ $<xref-section>>>.ast ];
	make (:xref($sections));
    }

    method xref-section($/) {
        my @entries = $<xref-entry>».ast;
        make {
	    obj-first-num => $<obj-first-num>.ast.value,
	    obj-count => $<obj-count>.ast.value,
	    :@entries,
        }
    }

    method xref-entry($/) {
        make {
            type   => $<obj-status>.ast,
            offset => $<byte-offset>.ast.value,
            gen-num  => $<gen-number>.ast.value,
            };
    }

    method obj-status:sym<free>($/)  { make 0 }
    method obj-status:sym<inuse>($/) { make 1 }

    method stream($/) { make ~$<encoded> }

}