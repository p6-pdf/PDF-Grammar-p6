use v6;

use PDF::Grammar::PDF::Actions;

# rules for constructing PDF::Grammar::FDF AST                                                                                                 

class PDF::Grammar::FDF::Actions
    is PDF::Grammar::PDF::Actions {

    method TOP($/) { make $<fdf>.ast.value }
    method fdf-header ($/) { make 'pdf-version' => $<pdf-version>.Rat }
    method fdf($/) {
	my $bodies-ast = [ $<body>>>.ast.map({ .value.item }) ];
        make 'fdf' => {
	    header => $<fdf-header>.ast,
	    body => $bodies-ast,
        }
     }
};
