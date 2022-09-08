L = pdflatex
E = pdf

all: list cd new probation dvds book vsi

new: new.$(E)

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
	$(L) wantlist.tex

dvds.$(E): dvds.tex
	$(L) dvds.tex

books.$(E): books.tex books.bbl books2.bbl books.sty
	- $(L) books
	./cullrefs.prl books
	- $(L) books
	- $(L) books

books.bbl: books.bib abbrevs.bib books.bst
	$(L) books.tex
	bibtex books

books2.bbl: books2.bib abbrevs.bib books.bst
	$(L) books2.tex
	bibtex books2

new.$(E): new.tex new.bbl books.sty
	- $(L) new
	$(L) new

new.bbl: new.bib abbrevs.bib books.bst
	$(L) new.tex
	bibtex new

probation.$(E): probation.tex probation.bbl books.sty
	- $(L) probation
	$(L) probation

probation.bbl: books.bib books2.bib abbrevs.bib books.bst
	$(L) probation.tex
	bibtex probation

vsi.$(E): vsi.tex vsi.bbl books.sty
	- $(L) vsi
	$(L) vsi

vsi.bbl: books.bib books2.bib abbrevs.bib books.bst
	$(L) vsi.tex
	bibtex vsi

cd.$(E): cd.tex cd.ltx 
	$(L) cd.tex

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
