var artists = new Set()
var circles = new Set()
var tags = new Set()
var aopts = document.getElementById("ArtistOptions")
var copts = document.getElementById("CircleOptions")
var topts = document.getElementById("TagOptions")
var s_rate = document.getElementById("SearchRate")
var s_kw = document.getElementById("SearchKw")
var sf = document.getElementById("SearchForm")
var sorters = document.getElementsByName("sorter")
var sort_status = {
  by: "btime",
  desc: false,
  type: null,
  default: "1970-01-01"
}

function initialize_metadata() {
  for (const i in meta) {
    const actresses = meta[i].actress
    for (const j of actresses) {
      artists.add(j)
    }
    for (const j of meta[i].tags) {
      tags.add(j)
    }
    circles.add(meta[i].circle)
  }

  for (const i of artists) {
    if (i == null) {continue}
    const opt = document.createElement("option")
    const val = document.createTextNode(i)
    opt.value = i
    opt.appendChild(val)
    aopts.appendChild(opt)
  }
  for (const i of circles) {
    if (i == null) {continue}
    const opt = document.createElement("option")
    const val = document.createTextNode(i)
    opt.value = i
    opt.appendChild(val)
    copts.appendChild(opt)
  }
  for (const i of tags) {
    if (i == null) {continue}
    const opt = document.createElement("option")
    const val = document.createTextNode(i)
    opt.value = i
    opt.appendChild(val)
    topts.appendChild(opt)
  }
}

function create_table(cond={}) {
  const list_body = document.getElementById("ListBody")
  const tbody = document.createElement("tbody")
  let entities = []
  for (const i in meta) {
    if (cond.tag && !meta[i].tags?.includes(cond.tag)) { ;continue }
    if (cond.actress && !meta[i].actress?.includes(cond.actress)) { continue }
    if (cond.circle && !meta[i].circle?.includes(cond.circle)) { continue }
    if (cond.rate && (meta[i].rate || 0) < cond.rate ) { continue }
    if (cond.keyword && !i.includes(cond.keyword) && !meta[i].description?.includes(cond.keyword)) { continue }
    entities.push(i)
  }

  // Sorting
  const desc_adjust = sort_status.desc ? -1 : 1
  switch (sort_status.type) {
    case "str[]":
      entities = entities.sort((a,b) => {
        const va = meta[a][sort_status.by]?.join(" ") || sort_status.default
        const vb = meta[b][sort_status.by]?.join(" ") || sort_status.default
        if (va < vb) { return -1 * desc_adjust }
        else if (va > vb) { return 1 * desc_adjust }
        else { return 0 }
      })
      break
    default:
      entities = entities.sort((a,b) => {
        const va = sort_status.by === "key" ? a : (meta[a][sort_status.by] || sort_status.default)
        const vb = sort_status.by === "key" ? b: (meta[b][sort_status.by] || sort_status.default)
        if (va < vb) { return -1 * desc_adjust }
        else if (va > vb) { return 1 * desc_adjust }
        else { return 0 }
      })
  }
  for (const i of entities) {
    const tr = document.createElement("tr")
    const cover = document.createElement("td")
    cover.innerHTML = `<img src="${meta[i].path.replace("?", "%3F").replace("#", "%23")}/${meta[i].imgpath || "thumb.jpg"}" />`
    tr.appendChild(cover)
    const title = document.createElement("td")
    title.innerHTML = `<a href="dlvfol://${meta[i].path.replace("?", "%3F").replace("#", "%23")}">${i}</a>`
    tr.appendChild(title)
    const circle = document.createElement("td")
    circle.innerHTML = meta[i].circle
    tr.appendChild(circle)
    const series = document.createElement("td")
    series.innerHTML = meta[i].series
    tr.appendChild(series)
    const actress = document.createElement("td")
    actress.innerHTML = meta[i].actress.join(", ")
    tr.appendChild(actress)
    const date = document.createElement("td")
    date.innerHTML = meta[i].btime
    tr.appendChild(date)
    const tags = document.createElement("td")
    tags.innerHTML = meta[i].tags.join(", ")
    tr.appendChild(tags)
    const duration = document.createElement("td")
    duration.innerHTML = meta[i].duration || ""
    tr.appendChild(duration)
    const rate = document.createElement("td")
    if (!meta[i].rate) { meta[i].rate = 0 }
    rate.innerHTML = ("★".repeat(meta[i].rate) + "☆".repeat(5 - meta[i].rate))
    tr.appendChild(rate)
    const description = document.createElement("td")
    if (meta[i].description) {
      const description_body = document.createElement("span")
      description_body.title = meta[i].description
      description_body.appendChild(document.createTextNode("🗒"))
      description.appendChild(description_body)
    }
    tr.appendChild(description)
    const filelist = document.createElement("td")
    filelist.className = "filelist filelist_col"
    const filelist_ul = document.createElement("ul")
    for (const file of meta[i].filelist) {
      const li = document.createElement("li")
      const li_text = document.createTextNode(file)
      li.appendChild(li_text)
      filelist_ul.appendChild(li)
    }
    filelist.appendChild(filelist_ul)
    tr.appendChild(filelist)

    tbody.appendChild(tr)
  }
  tbody.id = "ListBody"
  list_body.replaceWith(tbody)
}

function show(e) {
  create_table({
    tag: topts.value,
    actress: aopts.value,
    circle: copts.value,
    rate: s_rate.value,
    keyword: s_kw.value
  })
}

initialize_metadata()
create_table()

sf.addEventListener("change", show)

sorters.forEach(i => {
  i.addEventListener("click", e => {
    if ( sort_status.by === i.dataset.prop ) {
      sort_status.desc = !sort_status.desc
    } else {
      sort_status.desc = false
    }
    sort_status.by =  i.dataset.prop
    switch (i.dataset.type) {
      case "num":
        sort_status.type = null
        sort_status.default = 0
        break
        case "dstr":
          sort_status.type = null
          sort_status.default = "1970-01-01"
          break
        case "str[]":
          sort_status.type = "str[]"
          sort_status.default = []
          break
        default:
        sort_status.type = null
        sort_status.default = ""
    }
    show(e)
  })
})

document.getElementById("HideFilelist").addEventListener("change", function(e) {
  const table = document.getElementById("MainTable")
  if (e.target.checked) {
    table.classList.remove("hide_filelist")
  } else {
    table.classList.add("hide_filelist")
  }
})