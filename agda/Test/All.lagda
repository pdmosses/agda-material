First text line

\begin{code}
module Test.All where

-- import Test
import Test2
import Test3
import Test.Sub.Base

-- Just testing...
\end{code}

Literate prose is included in generated webpages and PDFs.
It is generally rendered as plain text:

* Blank lines produce paragraph breaks,
  but line breaks and indentation are otherwise ignored.

* URLs do not become links.

* Characters treated as special by LaTeX lead to errors when generating PDFs.

* Use of Unicode characters in generated PDFs may require mapping them to
  LaTeX markup.

The subset of LaTeX math markup supported by KaTeX (https://katex.org) is
rendered correctly in webpages and PDFs.
The following examples are from the Material for MkDocs website:

$$
\cos x=\sum_{k=0}^{\infty}\frac{(-1)^k}{(2k)!}x^{2k}
$$

The homomorphism $f$ is injective if and only if its kernel is only the
singleton set $e_G$, because otherwise $\exists a,b\in G$ with $a\neq b$ such
that $f(a)=f(b)$.

\begin{code}
-- More code
\end{code}

Last text line