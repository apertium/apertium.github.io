#lang scribble/manual

@(require scriblib/figure
          "references.rkt"
          "util.rkt")

@title[#:tag "stream-format" #:version "3.5.2"]{Format specification of the
data stream between modules}

@section{Introduction}

The format of the data that circulate between the engine's modules has to be
specified so that document processing is more effective and transparent. The
proposed system design (see @secref["engine"]) imposes the need to use three
different data stream types, as shown in @Figure-ref["fig:fdatos"].

The stream format is text-based to facilitate, among other things, the
diagnosis of possible system errors, since it is easy to manipulate the stream
in order to reproduce the phenomena that are to be tested, and change it to see
the result. Other benefits of using text streams are that it is possible to
test independently the output of each module, and that it allows for fast
building of prototypes to test the system's global performance, the validity of
linguistic data, etc.

@figure["fig:fdatos" "The different data stream types in the machine
        translation system. See the text for its description."
        @image["fdatos.svg" #:scale 0.9] #:style center-figure-style ]

The data stream types are:

@itemize[

@item{@italic{Data stream with format:} It is the text in its original format,
with no further marks: XML, ANSI text, RTF, HTML, etc. Since it is the original
format of the documents, nothing needs to be specified about it except the name
of the format.}

@item{@italic{Data stream without format:} It is the text with
@italic{superblanks}, that is, with special characters that encapsulate the
format (see @secref["formats"]); superblanks are treated by the linguistic
modules as blanks between words (with some exceptions). This is the format
generated by the @a-module{de-formatter} and used by the
@a-module{re-formatter} when generating the final translated document.}

@item{@italic{Segmented data stream:} In this format, apart from superblanks,
lexical units that are to be translated are delimited also with special
characters. These characters are put by the morphological analyser and deleted
by the generator, which delivers the final surface forms.}

]

We describe next the characteristics of the data stream used between the
modules of the translator, that is, the second and the third stream types. In
general terms, it is a plain text format marked with characters that have a
special meaning. This format is intended for the processing in servers that
translate large volumes of text.

Some of the formats that the engine can process may contain extensive blocks of
information in binary format --- RTF for instance, that may include bitmap
images. To enable an efficient processing of this type of documents, we
designed a way to extract this information and restore it after translation has
been performed; see @secref{formats} for a complete description.

@section{Data stream without format}

Data stream without format is output by the de-formatter and by the generator,
@;{no del tot: postgenerador} and is used as input by the morphological
analyser, the post-generator and the re-formatter.

In the subsection of this section you can find a description of the method to
delimit @italic{superblanks} and @italic{extensive superblanks}. As an example
we will use the HTML document in @Figure-ref{fg:docorigtext}.

@figure["fg:docorig" "Example of HTML document" #:style left-figure-style

@verbatim{
<html>
  <head>
    <title>Title</title>
  </head>
  <body>
    <p>Divided
       sentence</p>
  </body>
</html>
}

]
The structural elements that @sout{must include} this data stream type
@red{must include} are the following:

@itemlist[

@item{@italic{Superblanks}. Blocks that contain segments of format information
included in the documents, when these are short.}

@item{@italic{Extensive superblanks}. Marks that are used to specify external
documents that include segments of format information for the document being
processed, when these segments are long.}

@item{@italic{Text}. The document text that can be translated.}

@item{@italic{Artificial sentence endings}. When the format in the document
suggests a sentence separation that is not signalled by any punctuation mark
(for instance, titles with no full stop at the end, or the content of cells in
a table), the format processing must have a mechanism (invisible for the user)
that enables the marking of these sentence endings.}

@item{@italic{Special characters protection (for non-XML stream)}. Characters
that must be protected to avoid conflict with the ones used in the data stream
format.}

]

@; \subsection{XML format}

@; En este tipo de flujo se usa el elemento \texttt{<\textbf{b}>} para definir los 
@; superblancos y los superblancos extensos.  Para el caso de los 
@; \textbf{superblancos} la sintaxis es la siguiente:

@; \begin{small}
@; \begin{alltt} % <\textbf{b}>\textit{contenido del bloque de formato}</\textbf{b}>
@; \end{alltt}
@; \end{small}

@; Hay que resaltar que para los formatos basados en SGML, es necesario
@; incluir el formato en bloques \texttt{<![CDATA[\ldots]]>} dentro de
@; las marcas indicadas. \nota{millor dir com són: prendre text de EAMT
@; '05 - Gema} Por su parte, los \textit{superblancos extensos} se deben 
@; expresar, a modo de atributos, de la siguiente manera:

@; \begin{small}
@; \begin{alltt} % <\textbf{b} \textsl{filename}="\textit{nombre de fichero}"/>
@; \end{alltt}
@; \end{small}

@; El \emph{texto} estará incluido entre los elementos \textbf{b} que se 
@; acaban de explicar sin ninguna marca de estructura particular.

@; Los \emph{finales de frase artificiales} se expresan mediante un punto y un 
@; superblanco vacío inmediatamente a continuación.

@; \begin{small}
@; \begin{alltt} % .<\textbf{b}/>
@; \end{alltt}
@; \end{small}

@; Resumiendo, el flujo de datos de un documento en cualquier formato de los que 
@; trata el traductor se reduce a otro documento XML que debe cumplir la 
@; siguiente DTD:

@; \begin{small}
@; \begin{alltt} % <!\textsl{ELEMENT} \textbf{document} (b|\textsl{#PCDATA})*> 
@; <!\textsl{ELEMENT} \textbf{b} (\textsl{#PCDATA}?)> 
@; <!\textsl{ATTLIST} b filename \textsl{CDATA} \textsl{#IMPLIED}>
@; \end{alltt}
@; \end{small}

@; El resultado de encapsular el formato del fichero de la 
@; figura~\ref{fg:docorig} en el flujo con formato XML se ve en la 
@; figura~\ref{fg:docorigXML}.  Si hubiese algún superblanco que por su longitud
@; se convirtiese en un superblanco extenso, la forma de especificarlo sería como sigue:
@; \begin{small}
@; \begin{alltt} % <\textbf{b} \textsl{filename}="/tmp/ficherotemporal"/>
@; \end{alltt}
@; \end{small}donde \texttt{"/tmp/ficherotemporal"} es un fichero que 
@; contiene el superblanco extenso para que pueda ser recuperado por el reformateador.

@; \begin{figure}
@; \begin{small}
@; \begin{alltt} % <?\textbf{xml} \textsl{version}="1.0" \textsl{encoding}="iso-8859-15"?> 
@; <\textbf{document}> 
@; <\textbf{b}><![CDATA[<html> % <head>
@; <title>]]></\textbf{b}>Título.<\textbf{b}/><\textbf{b}><![CDATA[</title>
@; </head> % <body> % <p>]]></\textbf{b}>Frase<\textbf{b}><![CDATA[ 
@; ]]></\textbf{b}>dividida.<\textbf{b}/><\textbf{b}><![CDATA[ % </body>
@; </html>]]></\textbf{b}> % </\textbf{document}>
@; \end{alltt}
@; \end{small}
@; \caption{El documento de la figura \protect\ref{fg:docorig} con el
@; formato encapsulado usando marcas en XML y segmentos
@; \texttt{<![CDATA[\ldots]]>}}
@; \label{fg:docorigXML}
@; \end{figure}

@; \subsection{Formato no XML}

@subsection[#:tag "noxml1"]{Stream format}

This format is based on the one used in the machine translation systems
@tt{interNOSTRUM} @~cite[canals01b]@~cite[garridoalenda01p]@~cite[garrido99j]
and @tt{Traductor Universia} @~cite[garrido03p]@~cite[gilabert03j].

In this stream type, the characters @tt{[} and @tt{]} are used to indicate
@italic{superblanks}, as shown in the following example:

@verbatim{
[superblank content]
}

In the case of @italic{extensive superblanks}, the file name is specified using
the at sign @tt{@"@"}:

@verbatim{
[@"@"file name]
}

The @italic{text} is outside the superblank marks.

@italic{Artificial sentence endings} are expressed by a full stop and an empty
superblank right after it.

@verbatim{
.[]
}

The following table shows the @bold{protected characters}:

@tabular[#:style 'block
         #:column-properties '(left)
	 #:row-properties '(border)
(list (list @bold{Name} @bold{Character} @bold{Protected form} @bold{Meaning})
      (list "At" @"@" @(string-append "\\" @"@") "External superblank")
      (list "Slash" "/" "\\/" "Divider of meaning")
      (list "Backslash" "\\" "\\\\" "Protection character")
      (list "Caret" "^" "\\^" "Beginning of LF")
      (list "Opening square bracket" "[" "\\[" "Beginning of blank")
      (list "Closing square bracket" "]" "\\]" "End of blank")
      (list "Dollar" "$" "\\$" "End of LF")
      (list "Greater than" ">" "\\>" "Begin. of morph. symbol")
      (list "Less than" "<" "\\<" "End of moprh. symbol")
)]

@Figure-ref{fg:docorigtext} shows the document in @Figure-ref{fg:docorig} after
encapsulation.

@figure["fg:docorigtext" @elem{The document in @Figure-ref{fg:docorig} with
format encapsulated using square brackets} #:style left-figure-style

@verbatim{
[<html> 
  <head> 
    <title>]Title.[][</title> 
  </head>
  <body> 
    <p>]Divided[
       ]sentence.[][</p>
  </body> 
<html>]
}

]

@section{Segmented data stream}

Segmented data stream is the stream that circulates between the modules that
handle linguistic information in the translation engine. In this stream, words
are delimited and labelled. There are two types of segmented stream:

@itemlist[

@item{@italic{Ambiguous segmented stream}. Its main characteristic
is that words have a surface form and potentially more than one lexical form
(lexical multiform). This stream type is the format in which the morphological
analyser provides the input data for the part-of-speech tagger (see diagram
\ref{eq:formaanalizada} in page ~\pageref{formaanalizada} for a detailed
description of ambiguous segmented stream).}
 
@item{@italic{Unambiguous segmented stream}. It has only one lexical form for
each word and it does not include the surface form. This is the format in which
data circulate from the part-of-speech tagger to the transfer module, and from
this module to the generator (see diagram \ref{eq:formaanalizada2} in
page~\pageref{formaanalizada2} for a detailed description of the format of
unambiguous segmented stream).}

]

Furthermore, besides the information already marked in the data stream without
format, the new stream has to enable marking of the following information:

@itemlist[

@item{@italic{Lexical units}. A lexical unit is made of a surface form (in the
case of ambiguous segmented stream) plus one or more lexical forms (the
different possible analyses of the SF) with their grammatical symbols.}

@item{@italic{Surface forms (ambiguous segmented stream)}. The word as it
appears in the original text.}

@item{@italic{Lexical forms}. The lemma of the word and its grammatical
symbols.}

@item{@italic{Grammatical symbols}. They describe the morphological and
grammatical attributes of a surface form.}

]

@; \subsection{XML format}

@; Las \textit{palabras} se etiquetan de la forma que se muestra a 
@; continuación:

@; \begin{small}
@; \begin{alltt} % <\textbf{w}>\textit{información de la palabra}</\textbf{w}>
@; \end{alltt}
@; \end{small}

@; Para el caso del \textit{flujo de datos segmentado ambiguo}, la 
@; \textit{forma superficial} se indica en el interior de un elemento 
@; \texttt{<\textbf{w}>} mediante el contenido de un único elemento 
@;\texttt{<\textbf{sf}>}.  A continuación, se sitúan la forma o 
@;\textit{formas léxicas} que sean necesarias:

@; \begin{small}
@; \begin{alltt} % <\textbf{w}> % <\textbf{sf}>\textit{forma superficial}</\textbf{sf}> 
@; <\textbf{lf}>\textit{forma léxica 1}</\textbf{lf}> 
@; <\textbf{lf}>\textit{forma léxica 2 (opcional)}</\textbf{lf}> 
@; ...  % </\textbf{w}>
@; \end{alltt}
@; \end{small}

@; Para el caso del flujo no ambiguo, sólo se especifica una única forma léxica.


@; \begin{small}
@; \begin{alltt} % <\textbf{w}> % <\textbf{lf}>\textit{forma léxica}</\textbf{lf}> % </\textbf{w}>
@; \end{alltt}
@; \end{small}

@; %% \pagebreak

@; La DTD de este flujo de datos para textos \textit{sin desambiguar} es la % que se muestra en la figura~\ref{fg:ambdtd} a continuación.

@; \begin{figure}[here]
@; \begin{small}
@; \begin{alltt}
@;   <!\textsl{ELEMENT} \textbf{document} (b|w|\textsl{#PCDATA})*>
@;   <!-- atención, el #PCDATA anterior sigue siendo necesario para los 
@;        carácteres no etiquetados y que no forman parte del formato -->
@;   <!\textsl{ELEMENT} \textbf{b} (\textsl{#PCDATA}?)>
@;   <!\textsl{ATTLIST} b filename \textsl{CDATA} \textsl{#IMPLIED}>
@;   <!\textsl{ELEMENT} \textbf{w} (sf,lf+)>
@;   <!\textsl{ELEMENT} \textbf{sf} (\textsl{#PCDATA})>
@;   <!\textsl{ELEMENT} \textbf{lf} (\textsl{#PCDATA}|s)+>
@;   <!\textsl{ELEMENT} \textbf{s} \textsl{EMPTY}>
@;   <!\textsl{ATTLIST} s n \textsl{IDREF #REQUIRED}>
@; \end{alltt}
@; \end{small}
@; \caption{DTD para textos no desambiguados con formato XML}
@; \label{fg:ambdtd}
@; \end{figure}




@; Para los ya \textit{ desambiguados}, los textos deben cumplir la DTD de la figura~\ref{fg:desambdtd}.

@; \begin{alltt}
@;   <!\textsl{ELEMENT} \textbf{document} (b|w|\textsl{#PCDATA})*>
@;   <!-- atención, el #PCDATA anterior sigue siendo necesario para los 
@;        carácteres no etiquetados y que no forman parte del formato -->
@;   <!\textsl{ELEMENT} \textbf{b} (\textsl{#PCDATA}?)>
@;   <!\textsl{ATTLIST} b filename \textsl{CDATA} \textsl{#IMPLIED}>
@;   <!\textsl{ELEMENT} \textbf{w} (lf)>
@;   <!\textsl{ELEMENT} \textbf{lf} (\textsl{#PCDATA}|s)+>
@;   <!\textsl{ELEMENT} \textbf{s} \textsl{EMPTY}>
@;   <!\textsl{ATTLIST} s n \textsl{IDREF #REQUIRED}>
@; \end{alltt}
@; \end{small}
@; \caption{DTD para textos desambiguados con formato XML}
@; \label{fg:desambdtd}
@; \end{figure}

@; La figura~\ref{fg:docorigXML2} muestra un ejemplo de segmentación del flujo
@; que incluye la forma de encapsular el formato y la información léxica.  Este
@; ejemplo es para el caso de flujo segmentado ambiguo y corresponde al texto
@; HTML original de la figura~\ref{fg:docorig}. 

@; \begin{figure}[htbp]
@; \begin{small}
@; \begin{alltt}
@; <?\textbf{xml} \textsl{version}="1.0" \textsl{encoding}="iso-8859-15"?>
@; <document>
@; <\textbf{b}><![CDATA[<html>
@;   <head>
@;     <title>]]></\textbf{b}>
@; <\textbf{w}>
@;   <\textbf{sf}>Título<\textbf{sf}>
@;   <\textbf{lf}>Título<\textbf{s} \textsl{n}="n"/><\textbf{s} \textsl{n}="m"/><\textbf{s} \textsl{n}="sg"/></\textbf{lf}>
@; </\textbf{w}>
@; <\textbf{w}>
@;   <\textbf{sf}>.</\textbf{sf}>
@;   <\textbf{lf}>.<s n="sent"/></\textbf{lf}>
@; </\textbf{w}><\textbf{b}/>
@; <\textbf{b}><![CDATA[</title>
@;   </head>
@;   <body>
@;     <p>]]></\textbf{b}>
@; <\textbf{w}>
@;   <\textbf{sf}>Frase</\textbf{sf}>
@;   <\textbf{lf}>Frase<s n="n"/><s n="f"/><s n="sg"/></\textbf{lf}>
@; </\textbf{w}>
@; <\textbf{b}><![CDATA[
@;        ]]></\textbf{b}>
@; <\textbf{w}>
@;   <\textbf{sf}>dividida</\textbf{sf}>
@;   <\textbf{lf}>dividir<s n="vblex"/><s n="pp"/><s n="f"/><s n="sg"/></\textbf{lf}>
@; </\textbf{w}>
@; <\textbf{w}>
@;   <\textbf{sf}>.</\textbf{sf}>
@;   <\textbf{lf}>.<s n="sent"/></\textbf{lf}>
@; </\textbf{w}><\textbf{b}/>
@; <\textbf{b}><![CDATA[
@;   </body>
@; <html>]]></\textbf{b}>
@; </document>
@; \end{alltt}
@; \end{small}
@; \caption{Ejemplo de flujo segmentado con el formato encapsulado en XML,
@;   correspondiente al documento HTML de la figura~\ref{fg:docorig}.} 
@; \label{fg:docorigXML2}
@; \end{figure}
@;\subsection{Formato no XML}
@;\subsubsection{Formato de flujo}
@;\label{se:noxml2}

The symbols @tt{^} for word beginning and @tt{$} for word end are used to
delimit @italic{words}, as shown in this example:

@verbatim{
^word$
}

To separate the @italic{surface form} and the following @italic{lexical forms},
the symbol @tt{/} is used. This separator only has sense in the ambiguous
segmented stream, since in the unambiguous stream there is only the lexical
form. It is used as follows:

@verbatim{
^surface form/lexical form 1/...$
}

Lexical forms can include symbols (generally located at the end), as shown in
the example of @Figure-ref{fg:docorigtext2}.

@figure["fg:docorigtext2" @elem{Example of segmented stream with format
encapsulated in non-XML format, corresponding to the HTML document in
@Figure-ref{fg:docorig}.} #:style left-figure-style

@verbatim{
[<html> 
   <head> 
     <title>]^Title/Title<n><m><sg>$^./.<sent>$[][</title>
   </head>
   <body> 
     <p>]^Divided/Divide<vblex><pp>/Divided<vblex><past>$[
        ]^sentence/sentence<n><sg>/sentence<vblex><inf>$^./.<sent>$[][</p>
  </body> 
<html>]
}

]
