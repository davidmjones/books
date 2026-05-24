P = lualatex
D = latex
E = pdf

export TEXINPUTS=lib/texmf:
export BSTINPUTS=lib/texmf/bst:
export BIBINPUTS=data

all: list cd new probation dvds book vsi

new: new.dvi

probation: probation.tex probation.$(E)

vsi: vsi.tex vsi.$(E) vsi2.pdf

book: books.$(E)

cd: cd.$(E)

dvds: dvds.$(E)

b: book

c: cd

g: list

list: wantlist.$(E)

wantlist.$(E): wantlist.tex
	$(P) wantlist.tex

dvds.$(E): dvds.tex
	$(P) dvds.tex

books.$(E): books.tex books.bbl books2.bbl lib/texmf/books.sty
	- $(P) books
	./bin/cullrefs.prl books
	- $(P) books
	- $(P) books

books.bbl: data/books.bib data/abbrevs.bib lib/texmf/bst/books.bst
	$(P) books.tex
	bibtex books

books2.bbl: data/books2.bib data/abbrevs.bib lib/texmf/bst/books.bst
	$(P) books2.tex
	bibtex books2

new.dvi: new.tex new.bbl lib/texmf/books.sty
	- $(D) new
	$(D) new

new.bbl: data/new.bib data/abbrevs.bib lib/texmf/bst/books.bst
	$(P) new.tex
	bibtex new

probation.$(E): probation.tex probation.bbl lib/texmf/books.sty
	- $(P) probation
	$(P) probation

probation.bbl: data/books.bib data/books2.bib data/abbrevs.bib lib/texmf/bst/books.bst
	$(P) probation.tex
	bibtex probation

vsi.$(E): vsi.tex vsi.bbl lib/texmf/books.sty
	- $(P) vsi
	$(P) vsi

vsi.bbl: data/books.bib data/books2.bib data/abbrevs.bib lib/texmf/bst/books.bst
	$(P) vsi.tex
	bibtex vsi

cd.$(E): cd.tex cd.ltx 
	$(P) cd.tex

cd.ltx: data/cd.db lib/perl/CD.pm
## There has *got* to be a better way to do this
	if (egrep -n '^ +$$' cd.db) ; \
		then false; \
		else true; \
	fi
	./bin/cd2ltx data/cd.db > cd.ltx

vsi2.pdf: data/vsi.txt
	enscript -2 data/vsi.txt -o vsi2.ps
	distill vsi2.ps
	-rm vsi2.ps

install: books.pdf vsi2.pdf
	install -m 0444 -t /var/www/html/docs books.pdf vsi2.pdf

clean:
	-rm *.aux *.bbl *.dvi *.blg *.log *.out cd.ltx

veryclean: clean
	-rm *.pdf
