DO (GETENV("userprofile") + "\Kawix\Shide\interop")

local json1, json2 , lib
PUBLIC result1, result2

TEXT TO m.json1 NOSHOW 
{
  "image": {
    "width":  800,
    "height": 600,
    "title":  "View from 15th Floor",
    "thumbnail": {
      "url": "http://www.example.com/image/481989943",
      "height": 125,
      "width":  100
    },
    "visible": true,
    "ids": [116, 943, 234, 38793]
  }
}
ENDTEXT 

TEXT TO m.json2 NOSHOW 
[
  1,
  2,
  [3, 4, 5, 6],
  {
    "id": 1,
    "name": "A wooden door",
    "price": 12.50,
    "tags": ["home", "wooden"]
  }
]
ENDTEXT 

lib = _screen.nodeinterop.loadlibrary("json.parse")

* you can put a breakpoint here, to inspect the variables
result1 = lib.parse(m.json1)
result2 = lib.parse(m.json2)

* probe first result 
MESSAGEBOX(m.result1.image.title)
MESSAGEBOX(m.result1.image.thumbnail.url)

* second result is a collection (json arrays are transformed to collections)
MESSAGEBOX(m.result2.item[1])
MESSAGEBOX(m.result2.item[4].name)




