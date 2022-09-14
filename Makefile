P = pdflatex
D = latex
E = pdf

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

books.$(E): books.tex books.bbl books2.bbl books.sty
	- $(P) books
	./cullrefs.prl books
	- $(P) books
	- $(P) books

books.bbl: books.bib abbrevs.bib books.bst
	$(P) books.tex
	bibtex books

books2.bbl: books2.bib abbrevs.bib books.bst
	$(P) books2.tex
	bibtex books2

new.dvi: new.tex new.bbl books.sty
	- $(D) new
	$(D) new

new.bbl: new.bib abbrevs.bib books.bst
	$(P) new.tex
	bibtex new

probation.$(E): probation.tex probation.bbl books.sty
	- $(P) probation
	$(P) probation

probation.bbl: books.bib books2.bib abbrevs.bib books.bst
	$(P) probation.tex
	bibtex probation

vsi.$(E): vsi.tex vsi.bbl books.sty
	- $(P) vsi
	$(P) vsi

vsi.bbl: books.bib books2.bib abbrevs.bib books.bst
	$(P) vsi.tex
	bibtex vsi

cd.$(E): cd.tex cd.ltx 
	$(P) cd.tex

cd.ltx: cd.db CD.pm
## There has *got* to be a better way to do this
	if (egrep -n '^ +$$' cd.db) ; \
		then false; \
		else true; \
	fi
	./cd2ltx cd.db > cd.ltx

vsi2.pdf: vsi.txt
	enscript -2 vsi.txt -o vsi2.ps
	distill vsi2.ps
	-rm vsi2.ps

install: books.pdf vsi2.pdf
	install -m 0444 -t /var/www/html/docs books.pdf vsi2.pdf
