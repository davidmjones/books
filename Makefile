L = latex#2e

all: list cd new probation dvds book

new: new.dvi

probation: probation.dvi

book: books.dvi

cd: cd.dvi

dvds: dvds.dvi

b: book

c: cd

g: list

list: wantlist.dvi

wantlist.dvi: wantlist.tex
	$(L) wantlist.tex

dvds.dvi: dvds.tex
	$(L) dvds.tex

ps: cd.dvi books.dvi wantlist.dvi new.dvi probation.dvi
	dvips cd.dvi -o
	dvips wantlist.dvi -o
	dvips books.dvi -o
	dvips new.dvi -o
	dvips probation.dvi -o

print: ps
	lpr -Pduplex cd.ps
	lpr -Pduplex wantlist.ps
	lpr -Pduplex books.ps
	lpr -Pduplex new.ps
	lpr -Pduplex probation.ps

books.dvi: books.tex books.bbl books2.bbl books.sty
	- $(L) books
	./cullrefs.prl books
	- $(L) books

books.bbl: books.bib abbrevs.bib books.bst
	$(L) books.tex
	bibtex books

books2.bbl: books2.bib abbrevs.bib books.bst
	$(L) books2.tex
	bibtex books2

new.dvi: new.tex new.bbl books.sty
	- $(L) new
	$(L) new

new.bbl: new.bib abbrevs.bib books.bst
	$(L) new.tex
	bibtex new

probation.dvi: probation.tex probation.bbl books.sty
	- $(L) probation
	$(L) probation

probation.bbl: probation.bib probation2.bib books.bib books2.bib abbrevs.bib books.bst
	$(L) probation.tex
	bibtex probation

cd.dvi: cd.tex cd.ltx 
	$(L) cd.tex

cd.ltx: cd.db CD.pm
## There has *got* to be a better way to do this
	if (egrep -n '^ +$$' cd.db) ; \
		then false; \
		else true; \
	fi
	./cd2ltx cd.db > cd.ltx
