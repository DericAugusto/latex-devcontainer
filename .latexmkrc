# .latexmkrc
$pdf_mode = 1;
$interaction = 'nonstopmode';
$bibtex_use = 2;
# Output directories are provided by Makefile per project.
$pdflatex = 'pdflatex -synctex=1 -file-line-error -halt-on-error %O %S';
$max_repeat = 5;
add_cus_dep('glo','gls',0,'makeglossaries');
