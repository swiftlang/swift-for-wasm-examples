@main
struct Entrypoint {
  static func main() {
    var h1 = Document.global.createElement(name: JSString("h1"))
    let body = Document.global.body
    body.append(child: h1)
    h1.innerHTML = JSString("Hello, world!")
  }
}
