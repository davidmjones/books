% Based on:
% version 1.02 of vanilla format derived from plain family
% version 0.99a for BibTeX versions 0.99a or later, LaTeX version 2.09.
% Copyright (C) 1985, all rights reserved.
% Copyright (C) 1990, all rights reserved.
%
% Massachusetts Institute of Technology
% Laboratory for Computer Science
% William Ang  Feb. 12, 1990
%
% Modifications by David M. Jones  June 5, 1990
%
% Last Modified: August 10, 1992 by dmj
% 
% 3/17/1992: removed crossrefs
%
% vanilla.bst
% Machine Generated Code, on    Mon Aug 10 14:39:30 EDT 1992 
% Please make your changes in /a/dmjones/src/tocbst/tocstyles.doc 
%   alphabetic.bst, unsorted.bst, abbrev.bst, vanilla.bst
%
ENTRY
  { 
    abstract
    address
    author
    bookvol
    booktitle
    chapter
    cover
    crossrefonly
    edition
    editor
    howpublished
    impression
    imprint
    institution
    isbn
    isbn-13
    journal
    key
    month
    note
    number
    numvols
    organization
    firstimprint
    firstpublisher
    firstyear
    pages
    printing
    publisher
    reissued
    reprint
    reprint-note
    sortgroup
    sortkey
    school
    series
    title
    translator
    type
    volume
    year
  }
  {}
  { label }
INTEGERS { output.state before.all mid.sentence after.sentence after.block }
FUNCTION {init.state.consts}
{ #0 'before.all :=
  #1 'mid.sentence :=
  #2 'after.sentence :=
  #3 'after.block :=
}
STRINGS { s t }
FUNCTION {output.nonnull}
{ 's :=
  output.state mid.sentence =
    { ", " * write$ }
    { output.state after.block =
        { add.period$ write$
          newline$
          "\newblock " write$
        }
        { output.state before.all =
            'write$
            { add.period$ " " * write$ }
          if$
        }
      if$
      mid.sentence 'output.state :=
    }
  if$
  s
}
FUNCTION {output}
{ duplicate$ empty$
    'pop$
    'output.nonnull
  if$
}
FUNCTION {output.check}
{ 't :=
  duplicate$ empty$
    { pop$ "empty " t * " in " * cite$ * warning$ }
    'output.nonnull
  if$
}
FUNCTION {output.bibitem}
{ newline$
  "\bibitem{" write$
  cite$ write$
  "}" write$
  newline$
  ""
  before.all 'output.state :=
}
FUNCTION {fin.entry}
{ add.period$
  write$
  newline$
}
FUNCTION {new.block}
{ output.state before.all =
    'skip$
    { after.block 'output.state := }
  if$
}
FUNCTION {new.sentence}
{ output.state after.block =
    'skip$
    { output.state before.all =
        'skip$
        { after.sentence 'output.state := }
      if$
    }
  if$
}
FUNCTION {not}
{   { #0 }
    { #1 }
  if$
}
FUNCTION {and}
{   'skip$
    { pop$ #0 }
  if$
}
FUNCTION {or}
{   { pop$ #1 }
    'skip$
  if$
}
FUNCTION {new.block.checka}
{ empty$
    'skip$
    'new.block
  if$
}
FUNCTION {new.block.checkb}
{ empty$
  swap$ empty$
  and
    'skip$
    'new.block
  if$
}
FUNCTION {new.sentence.checka}
{ empty$
    'skip$
    'new.sentence
  if$
}
FUNCTION {new.sentence.checkb}
{ empty$
  swap$ empty$
  and
    'skip$
    'new.sentence
  if$
}
FUNCTION {field.or.null}
{ duplicate$ empty$
    { pop$ "" }
    'skip$
  if$
}
FUNCTION {emphasize}
{ duplicate$ empty$
    { pop$ "" }
    { "\emph{" swap$ * "}" * }
  if$
}
INTEGERS { nameptr namesleft numnames }
FUNCTION {format.sort.names}
{ 's :=
  #1 'nameptr :=
  s num.names$ 'numnames :=
  numnames 'namesleft :=
    { namesleft #0 > }
    { s nameptr
      nameptr #1 > 
        { "{ff~}{vv~}{ll}{, jj}" }
        { "{vv~}{ll}{, jj}{, ff}" }
      if$
      format.name$ 't :=
      nameptr #1 >
        { namesleft #1 >
            { ", " * t * }
            { numnames #2 >
                { "," * }
                'skip$
              if$
              t "others" =
                { " et~al." * }
                { " and " * t * }
              if$
            }
          if$
        }
        't
      if$
      nameptr #1 + 'nameptr :=
      namesleft #1 - 'namesleft :=
    }
  while$
}
FUNCTION {format.names}
{ 's :=
  #1 'nameptr :=
  s num.names$ 'numnames :=
  numnames 'namesleft :=
    { namesleft #0 > }
    { s nameptr "{ff~}{vv~}{ll}{, jj}" format.name$ 't :=
      nameptr #1 >
        { namesleft #1 >
            { ", " * t * }
            { numnames #2 >
                { "," * }
                'skip$
              if$
              t "others" =
                { " et~al." * }
                { " and " * t * }
              if$
            }
          if$
        }
        't
      if$
      nameptr #1 + 'nameptr :=
      namesleft #1 - 'namesleft :=
    }
  while$
}
FUNCTION {format.authors}
{ author empty$
    { "" }
    { author format.sort.names }
  if$
}
FUNCTION {format.editors}
{ editor empty$
    { "" }
    { editor format.sort.names
      editor num.names$ #1 >
        { ", editors" * }
        { ", editor" * }
      if$
    }
  if$
}
FUNCTION {format.translators}
{ translator empty$
    { "" }
    { translator format.sort.names
      translator num.names$ #1 >
        { ", translators" * }
        { ", translator" * }
      if$
    }
  if$
}
FUNCTION {format.title}
{ title empty$
    { "" }
    { title "t" change.case$ }
  if$
}
FUNCTION {n.dashify}
{ 't :=
  ""
    { t empty$ not }
    { t #1 #1 substring$ "-" =
        { t #1 #2 substring$ "--" = not
            { "--" *
              t #2 global.max$ substring$ 't :=
            }
            {   { t #1 #1 substring$ "-" = }
                { "-" *
                  t #2 global.max$ substring$ 't :=
                }
              while$
            }
          if$
        }
        { t #1 #1 substring$ *
          t #2 global.max$ substring$ 't :=
        }
      if$
    }
  while$
}
FUNCTION {format.date}
{ year empty$
    { month empty$
        { "" }
        { "there's a month but no year in " cite$ * warning$
          month
        }
      if$
    }
    { month empty$
        'year
        { month " " * year * }
      if$
    }
  if$
}
FUNCTION {format.btitle}
{ title duplicate$ empty$
    { pop$ "" }
    {
      "\booktitle{" swap$ * "}" *
      numvols empty$
        'skip$
        { " (" numvols * " vols)" * * }
      if$
    }
  if$
}
FUNCTION {tie.or.space.connect}
{ duplicate$ text.length$ #3 <
    { "~" }
    { " " }
  if$
  swap$ * *
}
FUNCTION {either.or.check}
{ empty$
    'pop$
    { "can't use both " swap$ * " fields in " * cite$ * warning$ }
  if$
}
FUNCTION {format.bvolume}
{ volume empty$
    { bookvol empty$
      { "" }
      { "book" bookvol tie.or.space.connect
        series empty$
          'skip$
          { " of " * series emphasize * }
        if$
      }
      if$
    }
    { "volume" volume tie.or.space.connect
      series empty$
        'skip$
        { " of " * series emphasize * }
      if$
      "volume and number" number either.or.check
    }
  if$
}
FUNCTION {format.number.series}
{ volume empty$ bookvol empty$ and
    { number empty$
        { series field.or.null }
        { output.state mid.sentence =
            { "number" }
            { "Number" }
          if$
          number tie.or.space.connect
          series empty$
            { "there's a number but no series in " cite$ * warning$ }
            { " in " * series * }
          if$
        }
      if$
    }
    { "" }
  if$
}
FUNCTION {format.edition}
{ edition empty$
    { "" }
    { output.state mid.sentence =
        { edition "l" change.case$ " edition" * }
        { edition "t" change.case$ " edition" * }
      if$
    }
  if$
}
FUNCTION {format.reprint}
{ reprint empty$
    { "" }
    { " reprinted " reprint * }
  if$
}
FUNCTION {format.impression}
{ impression empty$
    { "" }
    { impression }
  if$
}
FUNCTION {format.reissued}
{ reissued empty$
    { "" }
    { " reissued " reissued * }
  if$
}
INTEGERS { multiresult }
FUNCTION {multi.page.check}
{ 't :=
  #0 'multiresult :=
    { multiresult not
      t empty$ not
      and
    }
    { t #1 #1 substring$
      duplicate$ "-" =
      swap$ duplicate$ "," =
      swap$ "+" =
      or or
        { #1 'multiresult := }
        { t #2 global.max$ substring$ 't := }
      if$
    }
  while$
  multiresult
}
FUNCTION {format.pages}
{ pages empty$
    { "" }
    { pages multi.page.check
        { "pages" pages n.dashify tie.or.space.connect }
        { "page" pages tie.or.space.connect }
      if$
    }
  if$
}
FUNCTION {format.vol.num.pages}
{ volume field.or.null
  number empty$
    'skip$
    { "(" number * ")" * *
      volume empty$
        { "there's a number but no volume in " cite$ * warning$ }
        'skip$
      if$
    }
  if$
  pages empty$
    'skip$
    { duplicate$ empty$
        { pop$ format.pages }
        { ":" * pages n.dashify * }
      if$
    }
  if$
}
FUNCTION {format.chapter.pages}
{ chapter empty$
    'format.pages
    { type empty$
        { "chapter" }
        { type "l" change.case$ }
      if$
      chapter tie.or.space.connect
      pages empty$
        'skip$
        { ", " * format.pages * }
      if$
    }
  if$
}
FUNCTION {format.in.ed.booktitle}
{ booktitle empty$
    { "" }
    { editor empty$
        { "In " booktitle emphasize * }
        { "In " format.editors * ", " * booktitle emphasize * }
      if$
    }
  if$
}
FUNCTION {empty.misc.check}
{ author empty$ title empty$ howpublished empty$
  month empty$ year empty$ note empty$
  and and and and and
  key empty$ not and
    { "all relevant fields are empty in " cite$ * warning$ }
    'skip$
  if$
}
FUNCTION {format.thesis.type}
{ type empty$
    'skip$
    { pop$
      type "t" change.case$
    }
  if$
}
FUNCTION {format.tr.number}
{ type empty$
    { "Technical Report" }
    'type
  if$
  number empty$
    { "t" change.case$ }
    { number tie.or.space.connect }
  if$
}
FUNCTION {format.lecture.loc}
{ institution empty$
    { ""}
    { "Lecture given at " institution * }
  if$
}
FUNCTION {do.abstract}
{ abstract empty$
  'skip$
  { "\beginbibabs" write$
    newline$
    abstract write$
    newline$
    "\endbibabs" write$
    newline$ }
  if$
}
FUNCTION {article}
{ output.bibitem
  format.authors "author" output.check
  new.block
  format.title "title" output.check
  new.block
      journal emphasize "journal" output.check
      format.vol.num.pages output
      format.date "year" output.check
  new.block
  note output
  fin.entry
  do.abstract
}
FUNCTION {bachelorsthesis}
{ output.bibitem
  format.authors "author" output.check
  new.block
  format.title "title" output.check
  new.block
  "Bachelor's thesis" format.thesis.type output.nonnull
  school "school" output.check
  address format.date "year" output.check
  new.block
  note output
  fin.entry
  do.abstract
}

FUNCTION {do.publisher}
{
  firstyear empty$
    'skip$
    {
      reprint-note empty$
          { "Reprint" }
          { reprint-note }
      if$
      ": " * output
      before.all 'output.state :=
    }
  if$
  imprint output
  imprint empty$
    { publisher "publisher" output.check }
    {
      publisher empty$
        'skip$
        {
          before.all 'output.state :=
          " (" publisher ")" * * output.nonnull
        }
      if$
    }
  if$
}

FUNCTION {do.firstpublisher}
{
  firstimprint output
  firstimprint empty$
    { firstpublisher output }
    {
      firstpublisher empty$
        'skip$
        {
          before.all 'output.state :=
          " (" firstpublisher ")" * * output.nonnull
        }
      if$
    }
  if$
}

FUNCTION {do.book}
{ output.bibitem
  author empty$
    { editor empty$
        { format.translators "author, editor, and translator" output.check }
        { format.editors "author and editor" output.check }
      if$
    }
    { format.authors output.nonnull
%        "author and editor" editor either.or.check 
    }
  if$
  firstyear empty$
      { year empty$ 'skip$ { year output } if$ }
      { firstyear output }
  if$
  new.block
  format.btitle "title" output.check
      format.bvolume output
      new.block
      format.number.series output
      new.sentence
      do.firstpublisher
      new.sentence
      do.publisher
      address output
  format.edition output
  firstyear empty$
      'skip$
      { format.date "year" output.check }
  if$
  format.impression output
  format.reprint output
  format.reissued output
  new.block
  printing output
  new.block
  note output
  new.block
  author empty$
    'skip$
    { editor empty$
        'skip$
        { "Edited by " editor format.names * output }
      if$
    }
  if$
  author empty$ editor empty$ and
    'skip$
    {
        translator empty$
            'skip$
            { new.block
              "Translated by " translator format.names * output
            }
        if$
    }
  if$
  new.block
  isbn-13 empty$
    { isbn empty$
        { "" }
        { isbn }
       if$
    }
    { isbn-13 }
  if$
  duplicate$
  empty$
    { "" }
    { " " }
  if$
  cover empty$
    'pop$
    { * cover * }
  if$
  output
  fin.entry
  do.abstract
}
FUNCTION {book}
{ crossrefonly missing$
   { do.book }
   { crossrefonly "1" = 
      'skip$
      { do.book }
     if$
   }
  if$
}
FUNCTION {booklet}
{ output.bibitem
  format.authors output
  new.block
  format.title "title" output.check
  howpublished address new.block.checkb
  howpublished output
  address output
  format.date output
  new.block
  note output
  fin.entry
  do.abstract
}
FUNCTION {inbook}
{ output.bibitem
  author empty$
    { format.editors "author and editor" output.check }
    { format.authors output.nonnull
            "author and editor" editor either.or.check
    }
  if$
  new.block
  format.btitle "title" output.check
      format.bvolume output
      format.chapter.pages "chapter and pages" output.check
      new.block
      format.number.series output
      new.sentence
      publisher "publisher" output.check
      address output
  format.edition output
  format.date "year" output.check
  new.block
  note output
  fin.entry
  do.abstract
}
FUNCTION {incollection}
{ output.bibitem
  format.authors "author" output.check
  new.block
  format.title "title" output.check
      new.block
      format.in.ed.booktitle "booktitle" output.check
      format.bvolume output
      format.number.series output
      format.chapter.pages output
      new.sentence
      publisher "publisher" output.check
      address output
      format.edition output
      format.date "year" output.check
  new.block
  note output
  fin.entry
  do.abstract
}
FUNCTION {inproceedings}
{ output.bibitem
  format.authors "author" output.check
  new.block
  format.title "title" output.check
      new.block
      format.in.ed.booktitle "booktitle" output.check
      format.bvolume output
      format.number.series output
      format.pages output
      address empty$
        { organization publisher new.sentence.checkb
          organization output
          publisher output
          format.date "year" output.check
        }
        { address output.nonnull
          format.date "year" output.check
          new.sentence
          organization output
          publisher output
        }
      if$
  new.block
  note output
  fin.entry
  do.abstract
}
FUNCTION {conference} { inproceedings }
FUNCTION {lecture}
{ output.bibitem
  format.authors "author" output.check
  new.block
  format.title "title" output.check
  new.block
  format.lecture.loc "institution" output.check
  address output
  format.date "year" output.check
  new.block
  note output
  fin.entry
  do.abstract
}
FUNCTION {manual}
{ output.bibitem
  author empty$
    { organization empty$
        'skip$
        { organization output.nonnull
          address output
        }
      if$
    }
    { format.authors output.nonnull }
  if$
  new.block
  format.btitle "title" output.check
  author empty$
    { organization empty$
        { address new.block.checka
          address output
        }
        'skip$
      if$
    }
    { organization address new.block.checkb
      organization output
      address output
    }
  if$
  format.edition output
  format.date output
  new.block
  note output
  fin.entry
  do.abstract
}
FUNCTION {mastersthesis}
{ output.bibitem
  format.authors "author" output.check
  new.block
  format.title "title" output.check
  new.block
  "Master's thesis" format.thesis.type output.nonnull
  school "school" output.check
  address output
  format.date "year" output.check
  new.block
  note output
  fin.entry
  do.abstract
}
FUNCTION {misc}
{ output.bibitem
  format.authors output
  title howpublished new.block.checkb
  format.title output
  howpublished new.block.checka
  howpublished output
  format.date output
  new.block
  note output
  fin.entry
  do.abstract
  empty.misc.check
}
FUNCTION {phdthesis}
{ output.bibitem
  format.authors "author" output.check
  new.block
  format.btitle "title" output.check
  new.block
  "PhD thesis" format.thesis.type output.nonnull
  school "school" output.check
  address output
  format.date "year" output.check
  new.block
  note output
  fin.entry
  do.abstract
}
FUNCTION {do.proceedings}
{ output.bibitem
  editor empty$
    { organization output }
    { format.editors output.nonnull }
  if$
  new.block
  format.btitle "title" output.check
  format.bvolume output
  format.number.series output
  address empty$
    { editor empty$
        { publisher new.sentence.checka }
        { organization publisher new.sentence.checkb
          organization output
        }
      if$
      publisher output
      format.date "year" output.check
    }
    { address output.nonnull
      format.date "year" output.check
      new.sentence
      editor empty$
        'skip$
        { organization output }
      if$
      publisher output
    }
  if$
  new.block
  note output
  fin.entry
  do.abstract
}
FUNCTION {proceedings}
{ crossrefonly missing$
   { do.proceedings }
   { crossrefonly "1" = 
      'skip$
      { do.proceedings }
     if$
   }
  if$
}
FUNCTION {techreport}
{ output.bibitem
  format.authors "author" output.check
  new.block
  format.title "title" output.check
  new.block
  format.tr.number output.nonnull
  institution "institution" output.check
  address output
  format.date "year" output.check
  new.block
  note output
  fin.entry
  do.abstract
}
FUNCTION {unpublished}
{ output.bibitem
  format.authors "author" output.check
  new.block
  format.title "title" output.check
  new.block
  note "note" output.check
  format.date output
  fin.entry
  do.abstract
}
FUNCTION {default.type} { misc }
MACRO {jan} {"January"}
MACRO {feb} {"February"}
MACRO {mar} {"March"}
MACRO {apr} {"April"}
MACRO {may} {"May"}
MACRO {jun} {"June"}
MACRO {jul} {"July"}
MACRO {aug} {"August"}
MACRO {sep} {"September"}
MACRO {oct} {"October"}
MACRO {nov} {"November"}
MACRO {dec} {"December"}
MACRO {aal} {"Algebra and Logic"}
MACRO {aam} {"Advances in Applied Mathematics"}
MACRO {acmcs} {"ACM Computing Surveys"}
MACRO {acta} {"Acta Informatica"}
MACRO {ai} {"Artificial Intelligence"}
MACRO {ail} {"Algebra i Logika"}
MACRO {algolb} {"ALGOL Bulletin"}
MACRO {algor} {"Algorithmica"}
MACRO {ama} {"Advances in Mathematics"}
MACRO {apal} {"Annals of Pure and Applied Logic"}
MACRO {archiv} {"Archiv Math. Logik Grundlagenforsch"}
MACRO {cacm} {"Communications of the ACM"}
MACRO {cee} {"Computers and Electrical Engineering"}
MACRO {cmu} {"Carnegie-Mellon University"}
MACRO {cma} {"Computers and Mathematics with Applications"}
MACRO {comb} {"Combinatorica"}
MACRO {comj} {"Computer Journal"}
MACRO {comlan} {"Computer Languages"}
MACRO {comnet} {"Computer Networks"}
MACRO {cwi} {"Centrum voor Wiskunde en Informatica"}
MACRO {discomgeom} {"Discrete and Computational Geometry"}
MACRO {discomp} {"Distributed Computing"}
MACRO {eatcs} {"Bulletin of the European Association for Theoretical Computer Science"}
MACRO {i&comp} {"Information and Computation"}
MACRO {iandcomp} {"Information and Computation"}
MACRO {i&c} {"Information and Computation"}
MACRO {iandc} {"Information and Control"}
MACRO {ibmjrd} {"IBM Journal of Research and Development"}
MACRO {ibmsj} {"IBM Systems Journal"}
MACRO {icalp} {"International Colloquium on Automata, Languages, and Programming"}
MACRO {ieeeit} {"IEEE Transactions on Information Theory"}
MACRO {ieeese} {"IEEE Transactions on Software Engineering"}
MACRO {ieeetc} {"IEEE Transactions on Computers"}
MACRO {ieeetcad}
 {"IEEE Transactions on Computer-Aided Design of Integrated Circuits"}
MACRO {ieeetpami} {"IEEE Transactions on Pattern Analysis and Machine Intelligence"}
MACRO {ijpp} {"International Journal of Parallel Programming"}
MACRO {ipl} {"Information Processing Letters"}
MACRO {jacm} {"Journal of the ACM"}
MACRO {jalg} {"Journal of Algorithms"}
MACRO {jcss} {"Journal of Computer and System Sciences"}
MACRO {jir} {"Journal of Irreproducible Results"}
MACRO {jpdc} {"Journal of Parallel and Distributed Computing"}
MACRO {jsc} {"Journal of Symbolic Computation"}
MACRO {jsl} {"Journal of Symbolic Logic"}
MACRO {jvlsics} {"Journal of VLSI and Computer Systems"}
MACRO {lics} {"Logic in Computer Science"}
MACRO {lncs} {"Lecture Notes in Computer Science"}
MACRO {lnmath} {"Lecture Notes in Mathematics"}
MACRO {mathprog} {"Mathematical Programming"}
MACRO {mit} {"Mass\-a\-chu\-setts Insti\-tute of Tech\-no\-logy"}
MACRO {mitai} {"MIT Artificial Intelligence Laboratory"}
MACRO {miteecs} {"Department of Electrical Engineering and Computer Science, Mass\-a\-chu\-setts Insti\-tute of Tech\-no\-logy"}
MACRO {mitlcs} {"MIT Laboratory for Computer Science"}
MACRO {mitmath} {"Department of Mathematics, Mass\-a\-chu\-setts Insti\-tute of Tech\-no\-logy"}
MACRO {mitp} {"MIT Press"}
MACRO {mor} {"Mathematics of Operations Research"}
MACRO {mst} {"Mathematical Systems Theory"}
MACRO {networks} {"Networks"}
MACRO {or} {"Operations Research"}
MACRO {orl} {"Operations Research Letters"}
MACRO {pieee} {"Proceedings of the IEEE"}
MACRO {popl} {"Principles of Programming Languages"}
MACRO {prentice} {"Prentice-Hall, Inc."}
MACRO {scp} {"Science of Computer Programming"}
MACRO {sicomp} {"SIAM Journal on Computing"}
MACRO {siamjdm} {"SIAM Journal on Discrete Mathematics"}
MACRO {siamr} {"SIAM Review"}
MACRO {sigplan} {"ACM SIGPLAN Notices"}
MACRO {slfm} {"Studies in Logic and the Foundations of Mathematics"}
MACRO {sp&e} {"Software: Practice \& Experience"}
MACRO {spande} {"Software: Practice \& Experience"}
MACRO {tcs} {"Theoretical Computer Science"}
MACRO {tocs} {"ACM Transactions on Computer Systems"}
MACRO {tods} {"ACM Transactions on Database Systems"}
MACRO {tog} {"ACM Transactions on Graphics"}
MACRO {toms} {"ACM Transactions on Mathematical Software"}
MACRO {toois} {"ACM Transactions on Office Information Systems"}
MACRO {toplas} {"ACM Transactions on Programming Languages and Systems"}
MACRO {utm} {"Undergraduate Texts in Mathematics"}
MACRO   {zmlgm} {"Zeitschrift f\accent'177 ur Mathematische Logik und Grundlagen der Mathematik"}
READ
FUNCTION {sortify}
{ purify$
  "l" change.case$
}
INTEGERS { len }
FUNCTION {chop.word}
{ 's :=
  'len :=
  s #1 len substring$ =
    { s len #1 + global.max$ substring$ }
    's
  if$
}
FUNCTION {sort.format.names}
{ 's :=
  #1 'nameptr :=
  ""
  s num.names$ 'numnames :=
  numnames 'namesleft :=
    { namesleft #0 > }
    { nameptr #1 >
        { "   " * }
        'skip$
      if$
      s nameptr "{vv{ } }{ll{ }}{  ff{ }}{  jj{ }}" format.name$ 't :=
      nameptr numnames = t "others" = and
        { "et al" * }
        { t sortify * }
      if$
      nameptr #1 + 'nameptr :=
      namesleft #1 - 'namesleft :=
    }
  while$
}
FUNCTION {sort.format.title}
{ 't :=
  "A " #2
    "An " #3
      "The " #4 t chop.word
    chop.word
  chop.word
  sortify
  #1 global.max$ substring$
}
FUNCTION {author.sort}
{ author empty$
    { key empty$
        { "to sort, need author or key in " cite$ * warning$
          ""
        }
        { key sortify }
      if$
    }
    { author sort.format.names }
  if$
}
FUNCTION {author.editor.sort}
{ author empty$
    { editor empty$
        { translator empty$
            { key empty$
                { "to sort, need author, editor, or key in " cite$ * warning$
                  ""
                }
                { key sortify }
              if$
            }
          { translator sort.format.names }
          if$
        }
        { editor sort.format.names }
      if$
    }
    { author sort.format.names }
  if$
}
FUNCTION {author.organization.sort}
{ author empty$
    { organization empty$
        { key empty$
            { "to sort, need author, organization, or key in " cite$ * warning$
              ""
            }
            { key sortify }
          if$
        }
        { "The " #4 organization chop.word sortify }
      if$
    }
    { author sort.format.names }
  if$
}
FUNCTION {editor.organization.sort}
{ editor empty$
    { organization empty$
        { key empty$
            { "to sort, need editor, organization, or key in " cite$ * warning$
              ""
            }
            { key sortify }
          if$
        }
        { "The " #4 organization chop.word sortify }
      if$
    }
    { editor sort.format.names }
  if$
}
FUNCTION {presort}
{ 
  sortgroup field.or.null
  "      "
  *
  #1 #8 substring$
  sortkey empty$
  {
  type$ "book" =
  type$ "inbook" =
  or
    'author.editor.sort
    { type$ "proceedings" =
        'editor.organization.sort
        { type$ "manual" =
            'author.organization.sort
            'author.sort
          if$
        }
      if$
    }
  if$
  }
  { sortkey sortify }
  if$
  *
  "    "
  *
  firstyear empty$ { year } { firstyear } if$
  field.or.null sortify
  *
  "    "
  *
  title field.or.null
  sort.format.title
  *
  #1 entry.max$ substring$
  'sort.key$ :=
}
ITERATE {presort}
SORT
STRINGS { longest.label }
INTEGERS { number.label longest.label.width }
FUNCTION {initialize.longest.label}
{ "" 'longest.label :=
  #1 'number.label :=
  #0 'longest.label.width :=
}
FUNCTION {longest.label.pass}
{ number.label int.to.str$ 'label :=
  number.label #1 + 'number.label :=
  label width$ longest.label.width >
    { label 'longest.label :=
      label width$ 'longest.label.width :=
    }
    'skip$
  if$
}
EXECUTE {initialize.longest.label}
ITERATE {longest.label.pass}
FUNCTION {begin.bib}
{ 
%%    preamble$ empty$
%%      'skip$
%%      { preamble$ write$ newline$ }
%%    if$
%%    "\makeatletter" write$ newline$
%%    "\@ifundefined{beginbibabs}{\def\beginbibabs{\begin{quotation}\noindent}"
%%     write$ newline$
%%     "\def\endbibabs{\end{quotation}}}{}" write$ newline$
%%     "\makeatother" write$ newline$
%%     newline$
%%    "\providecommand{\noopsort}[1]{}" write$ newline$
%%    "\begin{thebibliography}{"  longest.label  * "}" * write$ newline$
}
EXECUTE {begin.bib}
EXECUTE {init.state.consts}
ITERATE {call.type$}
FUNCTION {end.bib}
{ newline$
%%  "\end{thebibliography}  " write$ newline$
}
EXECUTE {end.bib}
