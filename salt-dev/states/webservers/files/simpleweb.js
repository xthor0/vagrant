// simple web service
const http = require('http')
//const port = 8000

const requestHandler = (request, response) => {
  console.log(request.url)
  response.end(`<HEAD><HTML><H1>Welcome to {{ appname }}!</H1><b>Running on hostname {{ salt['grains.get']('id') }}</b><p>Served by a node.js process listening on TCP port ${process.env.PORT}</HTML></HEAD>\n`)
}

const server = http.createServer(requestHandler)

server.listen(process.env.PORT, (err) => {
  if (err) {
    return console.log('something bad happened', err)
  }

  console.log(`server is listening on ${process.env.PORT}`)
})
