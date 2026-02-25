///|
test "SyntaxElement wraps node and token" {
  let tok = CstToken::new(RawKind(9), "x")
  let st = SyntaxToken::new(tok, 5)
  let elem_tok = SyntaxElement::Token(st)
  inspect(elem_tok.start(), content="5")
  inspect(elem_tok.end(), content="6")

  let cst = CstNode::new(RawKind(20), [])
  let sn = SyntaxNode::from_cst(cst)
  let elem_node = SyntaxElement::Node(sn)
  inspect(elem_node.start(), content="0")
}

///|
test "SyntaxNode::from_cst creates root at offset 0" {
  let cst = CstNode::new(RawKind(22), [])
  let syntax = SyntaxNode::from_cst(cst)
  inspect(syntax.start(), content="0")
  inspect(syntax.end(), content="0")
  inspect(syntax.kind() == RawKind(22), content="true")
}

///|
test "SyntaxToken::start and end" {
  let tok = CstToken::new(RawKind(9), "hello")
  let st = SyntaxToken::new(tok, 3)
  inspect(st.start(), content="3")
  inspect(st.end(), content="8")
}

///|
test "SyntaxToken::kind and text" {
  let tok = CstToken::new(RawKind(9), "foo")
  let st = SyntaxToken::new(tok, 0)
  inspect(st.kind() == RawKind(9), content="true")
  inspect(st.text(), content="foo")
}

///|
test "SyntaxToken Show" {
  let tok = CstToken::new(RawKind(9), "foo")
  let st = SyntaxToken::new(tok, 3)
  inspect(st, content="SyntaxToken@[3,6)")
}

///|
test "SyntaxNode::all_children includes tokens and nodes" {
  let tok = CstToken::new(RawKind(9), "hi")
  let inner = CstNode::new(RawKind(20), [])
  let root = CstNode::new(
    RawKind(22),
    [CstElement::Token(tok), CstElement::Node(inner)],
  )
  let sn = SyntaxNode::from_cst(root)
  let children = sn.all_children()
  inspect(children.length(), content="2")
  inspect(children[0].start(), content="0")
  inspect(children[0].end(), content="2")
  inspect(children[1].start(), content="2")
}

///|
test "SyntaxNode::tokens returns only leaf tokens with offsets" {
  let t1 = CstToken::new(RawKind(9), "ab")
  let t2 = CstToken::new(RawKind(10), "cd")
  let inner = CstNode::new(RawKind(20), [CstElement::Token(t2)])
  let root = CstNode::new(
    RawKind(22),
    [CstElement::Token(t1), CstElement::Node(inner)],
  )
  let sn = SyntaxNode::from_cst(root)
  let toks = sn.tokens()
  inspect(toks.length(), content="1")
  inspect(toks[0].text(), content="ab")
  inspect(toks[0].start(), content="0")
}

///|
test "SyntaxNode::children computes offsets" {
  // Build: SourceFile containing a CstToken "hello"
  let tok = CstToken::new(RawKind(9), "hello")
  let child_elem = CstElement::Token(tok)
  let inner = CstNode::new(RawKind(20), [child_elem])
  let root = CstNode::new(RawKind(22), [CstElement::Node(inner)])
  let syntax = SyntaxNode::from_cst(root)
  let children = syntax.children()
  inspect(children.length(), content="1")
  inspect(children[0].start(), content="0")
  inspect(children[0].end(), content="5")
}
