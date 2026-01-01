```agda
module Test.Space.Markdown
  where         -- this line is indented 2 spaces
module _ where  -- this line is not indented
```

The above code block starts on the first line, and is followed by a blank line.

The following code block is not preceded by a blank line.
```agda
-- Agda does not require blank lines around code blocks.
```
It is also not followed by a blank line.

The following code block is preceded by a blank line, which is ignored in Markdown.

```agda
-- Agda allows blank lines around code blocks
```

It is followed by a blank line, which is ignored in Markdown.

Blank lines inside code blocks are preserved:

```agda

-- This code line has blank lines around it.

```

Agda does not generate any Markdown for completely empty code blocks.

```agda
```

The following empty-looking code block has multiple newlines and spaces:

```agda
    
  
```

They are preserved.

Agda code can be indented:

```agda
  -- This comment is indented 2 spaces.

  module _
    where
    -- This comment is indented 4 spaces.

-- This comment is not indented.
```

The code block itself can be indented:

  ```agda
  -- This indented comment is in an indented code block.
  ```