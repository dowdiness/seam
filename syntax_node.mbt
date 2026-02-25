///|
/// Ephemeral positioned view over a `CstToken`.
/// Mirrors `SyntaxNode` but for leaf tokens.
pub struct SyntaxToken {
  cst : CstToken
  offset : Int
}

///|
pub fn SyntaxToken::new(cst : CstToken, offset : Int) -> SyntaxToken {
  { cst, offset }
}

///|
pub fn SyntaxToken::start(self : SyntaxToken) -> Int {
  self.offset
}

///|
pub fn SyntaxToken::end(self : SyntaxToken) -> Int {
  self.offset + self.cst.text_len()
}

///|
pub fn SyntaxToken::kind(self : SyntaxToken) -> RawKind {
  self.cst.kind
}

///|
pub fn SyntaxToken::text(self : SyntaxToken) -> String {
  self.cst.text
}

///|
/// Show: compact form — "SyntaxToken@[start,end)"
pub impl Show for SyntaxToken with output(self, logger) {
  logger.write_string("SyntaxToken@[")
  logger.write_string(self.start().to_string())
  logger.write_string(",")
  logger.write_string(self.end().to_string())
  logger.write_string(")")
}

///|
pub impl Debug for SyntaxToken with to_repr(self) {
  Repr::literal("SyntaxToken@[\{self.start()},\{self.end()})")
}

///|
/// A child element — either an interior node or a leaf token, both positioned.
pub(all) enum SyntaxElement {
  Node(SyntaxNode)
  Token(SyntaxToken)
}

///|
pub fn SyntaxElement::start(self : SyntaxElement) -> Int {
  match self {
    Node(n) => n.start()
    Token(t) => t.start()
  }
}

///|
pub fn SyntaxElement::end(self : SyntaxElement) -> Int {
  match self {
    Node(n) => n.end()
    Token(t) => t.end()
  }
}

///|
/// Ephemeral positioned view over a `CstNode`.
///
/// A `SyntaxNode` pairs an immutable `CstNode` with the absolute byte
/// `offset` of its start in the source. Unlike `CstNode`, `SyntaxNode`
/// values are created on demand and are not cached or shared.
///
/// **Invariant:** `offset + cst.text_len` is the exclusive end byte.
pub struct SyntaxNode {
  cst : CstNode
  parent : SyntaxNode?
  offset : Int
}

///|
/// Full constructor. `parent` is `None` for root nodes.
/// Prefer `SyntaxNode::from_cst` for root construction.
pub fn SyntaxNode::new(
  cst : CstNode,
  parent : SyntaxNode?,
  offset : Int,
) -> SyntaxNode {
  { cst, parent, offset }
}

///|
/// Create a root SyntaxNode from a CstNode (offset = 0, no parent).
pub fn SyntaxNode::from_cst(cst : CstNode) -> SyntaxNode {
  SyntaxNode::new(cst, None, 0)
}

///|
/// Absolute byte offset of this node's start in the source.
pub fn SyntaxNode::start(self : SyntaxNode) -> Int {
  self.offset
}

///|
/// Exclusive byte offset of this node's end in the source (`start + text_len`).
pub fn SyntaxNode::end(self : SyntaxNode) -> Int {
  self.offset + self.cst.text_len
}

///|
/// The language-agnostic kind of the underlying `CstNode`.
pub fn SyntaxNode::kind(self : SyntaxNode) -> RawKind {
  self.cst.kind
}

///|
/// Child `SyntaxNode`s with computed absolute offsets. Leaf tokens are skipped;
/// only interior `CstNode` children are returned.
pub fn SyntaxNode::children(self : SyntaxNode) -> Array[SyntaxNode] {
  let result : Array[SyntaxNode] = []
  for offset = self.offset, i = 0; i < self.cst.children.length(); {
    match self.cst.children[i] {
      Node(cst_child) => {
        result.push(SyntaxNode::new(cst_child, Some(self), offset))
        continue offset + cst_child.text_len, i + 1
      }
      Token(token) => continue offset + token.text_len(), i + 1
    }
  }
  result
}
