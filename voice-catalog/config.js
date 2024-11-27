// BASIC Settings
var use_dlvfol = true

// LWMP Settings
var voice_library_dir, lwmp_server
if (location.href.slice(0, 4).toLowerCase() === "http") {
  voice_library_dir = "/path/to/dlsite/Voice/"
  lwmp_server = "http://foohost.local:8800/"
}