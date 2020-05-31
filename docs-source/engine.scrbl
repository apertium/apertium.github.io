#lang scribble/manual

@(require scriblib/figure
          scriblib/footnote
	  "references.rkt"
	  "util.rkt")

@define-footnote[footnote make-footnote]

@title[#:tag "engine" #:version "3.5.2"]{The shallow-transfer machine
translation engine}

This chapter describes briefly the structure of the shallow-transfer machine
translation engine, which is largely based on that of the existing systems for
Spanish--Catalan @tt{interNOSTRUM}@~cite[canals01b] @~cite[garridoalenda01p]
@~cite[garrido99j] and for Spanish--Portuguese @tt{Traductor Universia}
@~cite[garrido03p] @~cite[gilabert03j], both developed by the Transducens group
of the Universitat d'Alacant. @; call/cc from here
It is a classical indirect translation system
that uses a partial syntactic transfer strategy similar to the one used by some
commercial MT systems for personal computers.

The design of the system makes it possible to produce MT systems that are
@emph{fast} (translating tens of thousands of words per second on ordinary
desktop computers) and that achieve results that are, in spite of the errors,
reasonably intelligible and easily correctable. In the case of related
languages such as the ones involved in the project (Spanish, Galician,
Catalan), a mechanical word-for-word translation (with a fixed equivalent)
would produce errors that, in most cases, can be solved with a quite
rudimentary analysis (a morphological analysis followed by a superficial, local
and partial syntactic analysis) and with an appropriate treatment of lexical
ambiguities (mainly due to homography). The design of our system follows this
approach with very interesting results. The Apertium architecture uses
finite-state transducers for lexical processing, hidden Markov models for
part-of-speech tagging and finite-state-based chunking for structural transfer.

The translation engine consists of an @sout{8-module} @red{8-to-12 module}
@emph{assembly line}, which is represented in @Figure-ref["fig:modules"]. To
ease diagnosis and independent testing, modules communicate between them using
text streams. This way, the input and output of the modules can be checked at
any moment and, when an error in the translation process is detected, it is
easy to test the output of each module separately to track down the origin of
the error. At the same time, communication via text allows for some of the
modules to be used in isolation, independently from the rest of the MT system,
for other natural-language processing tasks, and enables the construction of
prototypes with modified or additional modules.

We decided to encode linguistic data files in
XML@footnote{@url{http://www.w3.org/XML/}}-based formats due to its
interoperability, its independence of the character set and the availability of
many tools and libraries that make easy the analysis of data in this format. As
stated in @~cite[ide00], XML is the emerging standard for data representation
and exchange in Internet. Technologies around XML include very powerful
mechanisms for accessing and editing XML documents, which will probably have a
significant impact on the development of tools for natural language processing
and annotated corpora.

@figure["fig:modules" "The modules that build the assembly line of the
        shallow-transfer machine translation system. Many monolingual packages
        in Apertium have both a statistical and Constraint Grammar-based
        morphological disambiguator. The 'discontiguous multioword processing'
        module, also called apertium-separable, has been introduced in 2018 and
        is optional. The current 'lexical selection module' has been added in
        2012. The number and type of structural transfer modules can vary from
        a single 'chunker' module, to a three-stage,
        'chunker-interchunk-postchunk' structural transfer with several modules
        at each stage. There is also alternative transfer module called
        apertium-recursive, which has been developed in 2019."
	
	@image["Apertium_system_architecture.png" #:scale 0.3] #:style
	center-figure-style ]

The modules Apertium consists of are the following:

@itemlist[

@item{The @a-module{de-formatter}, which separates the text to be translated
from the format information (RTF, HTML, etc.); its specification can be found
in @seclink["format"]{Section 4.6.1}. Format information is encapsulated so
that the rest of the modules treat it as blanks between words. For example, for
the HTML text in Spanish:

@verbatim{
es <em>una señal</em>
}

(``it is a sign'') the de-formatter encapsulates in brackets the HTML tags and
gives the output:

@verbatim{
es [<em>]una señal[</em>]
}

The character sequences in brackets are treated by the rest of the modules as
simple blanks between words.}

@item{

The @a-module{morphological analyser}, which tokenizes the text in
@italic{surface forms} (SF) (lexical units as they appear in texts) and
delivers, for each SF, one or more @italic{lexical forms} (LF) consisting of
@italic{lemma} (the base form commonly used in classic dictionary entries), the
@italic{lexical category} (noun, verb, preposition, etc.) and morphological
inflection information (number, gender, person, tense, etc.). Tokenization of a
text in SFs is not straightforward due to the existence, on the one hand, of
contractions (in Spanish, @italic{del}, @italic{teniéndolo}, @italic{vámonos};
in English, @italic{didn't}, @italic{can't}) and, on the other hand, of lexical
units made of more than one word (in Spanish, @italic{a pesar de}, @italic{echó
de menos}; in English, @italic{in front of}, @italic{taken into account}). The
morphological analyser is able to analyse these complex SFs and treat them
appropriately so that they can be processed by the next modules. In the case of
contractions, the system reads a single surface form and gives as output a
sequence of two or more lexical forms (for instance, the Spanish
preposition-article contraction @italic{del} would be analysed into two lexical
forms, one for the preposition @italic{de} and another one for the article
@italic{el}). Lexical units made of more than one word (multiwords) are treated
as single lexical forms and processed specifically according to its
type.@footnote{For more information about the treatment of multiwords, please
refer to page ~\pageref{ss:multipalabras}.}

Upon receiving as input the example text from the previous module, the
morphological analyser would deliver:

@verbatim{
^es/ser<vbser><pri><p3><sg>$[ <em>]
^una/un<det><ind><f><sg>/unir<vblex><prs><1><sg>/unir<vblex><prs><3><sg>$
^señal/señal<n><f><sg>$[</em>]
}

where each surface form has been analysed into one or more lexical forms:
@italic{es} has been analysed as one SF with lemma @italic{ser} (``to be''),
whereas @italic{una} receives three analyses: lemma @italic{un} (``one''),
determiner, indefinite, feminine, singular; lemma @italic{unir} (``to join''),
verb in subjunctive present, 1st person singular, and lemma @italic{unir}, verb
in subjunctive present, 3rd person singular.

This module is generated from a source language (SL) morphological dictionary,
the format of which is specified in Section 4.1.2. @; TODO secref
}

@item{The @a-module{part-of-speech tagger} chooses, using a statistical model
(hidden Markov model), one of the analyses of an ambiguous word according to
its context; in the previous example, the ambiguous word would be the surface
form @italic{una}, which can have three different analyses. A sizeable fraction
of surface forms (in Romance languages, for instance, around one out of every
three words) are ambiguous, that is, they can be analysed into more than one
lemma, more than one part-of-speech or have more than one inflection analysis,
and are therefore an important source of translation errors when the wrong
equivalent is chosen. The statistical model is trained on representative
source-language text corpora.
 
The result of processing the example text delivered by the morphological
analyser with the part-of-speech tagger would be:

@verbatim{
^ser<vbser><pri><p3><sg>$[ <em>]^un<det><ind><f><sg>$
^señal<n><f><sg>$[</em>]
}

where the correct lexical form (determiner) has been selected for the word
@italic{una}.


The specification of the part-of-speech tagger is in Section 4.2.} @; TODO
								   @; secref


@item{The @a-module{lexical transfer module}, that uses a bilingual dictionary
and is called by the structural transfer module, reads each LF of the SL and
delivers the corresponding target language (TL) lexical form. @sout{The
dictionary contains a single equivalent for each SL lexical form; that is, no
word-sense disambiguation is performed.} @red{The dictionary can contain
multiple translations for each SL lexical form. The next module in the pipeline
-- @a-module{lexical selector} -- will pick the translation equivalent that is
most appropriate.}  Multiwords are translated as a single unit. The lexical
forms in the running example would be translated into Catalan as follows:

@verbatim{
^ser<vbser>/ser<vbser>$
^un<det>/un<det>$
^señal<n><f>/senyal<n><m>$
}

This module is generated from a bilingual dictionary, which is described in
Section 4.1.2.} @; TODO secref

@item{The @a-module{structural transfer module}, which detects and processes
patterns of words (chunks or phrases) that need special processing due to
grammatical divergences between the two languages (gender and number changes,
word reorderings, changes in prepositions, etc.). This module is generated from
a file containing rules which describe the action to be taken for each pattern.
In the running example, the pattern formed by @tt{^un<det><ind><f><sg>$
^señal<n><f><sg>$} would be detected by a determiner--noun rule, which in this
case would change the gender of the determiner so that it agrees with the noun;
the result would be:

@verbatim{
^ser<vbser><pri><p3><sg>$[ <em>]^un<det><ind><m><sg>$
^senyal<n><m><sg>$[</em>]
}

The format of the structural transfer rules file, inspired in the one described
 in @~cite[garridoalenda01p], is specified in Section 4.5.} @; TODO secref

@item{The @a-module{morphological generator}, that, from a lexical form in the
target language, generates a suitably inflected surface form. The result for
the example phrase would be:

@verbatim{és[ <em>]un senyal[</em>]}

This module is generated from a morphological dictionary, which is described in
detail in Section 4.1.2.} @; TODO secref

@item{The @a-module{post-generator}, that performs some orthographic operations
in the TL such as contractions and apostrophations, and which is generated from
a transformation rules file the format of which is very similar to the format
of the mentioned dictionaries. Its format is specified in Section 4.1.2. In the
example text there is no need to perform any contraction or apostrophation.}

@item{The @a-module{re-formatter}, which restores the original format
information into the translated text; the result for the running example would
be the correct conversion of the text into HTML format:

@verbatim{és <em>un senyal</em>}

The specification of the re-formatter is described in Section 4.6.1.}]

The four lexical processing modules (morphological analyser, lexical transfer
module, morphological generator and post-generator) use a single compiler,
based on a class of @italic{finite-state transducers} @~cite[garrido99j], in
particular, letter transducers @~cite[roche97], @~cite[ortiz05j]; its
characteristics are described in Section 4.1.3.

@make-footnote[]
