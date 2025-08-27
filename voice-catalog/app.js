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

const titles = meta.titles
const soundindex = meta.soundindex

function initialize_metadata() {
  for (const i in titles) {
    const actresses = titles[i].actress
    for (const j of actresses) {
      artists.add(j)
    }
    for (const j of titles[i].tags) {
      tags.add(j)
    }
    circles.add(titles[i].circle)
  }

  for (const i of Array.from(artists).sort((a,b) => (soundindex.actress[a] || a).localeCompare(soundindex.actress[b] || b))) {
    if (i == null) {continue}
    const opt = document.createElement("option")
    const val = document.createTextNode(i)
    opt.value = i
    opt.appendChild(val)
    aopts.appendChild(opt)
  }
  for (const i of Array.from(circles).sort((a,b) => (soundindex.circle[a] || a || "").localeCompare(soundindex.circle[b] || b || ""))) {
    if (i == null) {continue}
    const opt = document.createElement("option")
    const val = document.createTextNode(i)
    opt.value = i
    opt.appendChild(val)
    copts.appendChild(opt)
  }
  for (const i of Array.from(tags).sort()) {
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
  for (const i in titles) {
    if (cond.tag && !titles[i].tags?.includes(cond.tag)) { ;continue }
    if (cond.actress && !titles[i].actress?.includes(cond.actress)) { continue }
    if (cond.circle && !titles[i].circle?.includes(cond.circle)) { continue }
    if (cond.rate && (titles[i].rate || 0) < cond.rate ) { continue }
    if (cond.keyword && !i.includes(cond.keyword) && !titles[i].description?.includes(cond.keyword)) { continue }
    entities.push(i)
  }

  // Sorting
  const desc_adjust = sort_status.desc ? -1 : 1
  switch (sort_status.type) {
    case "str[]":
      entities = entities.sort((a,b) => {
        const va = titles[a][sort_status.by]?.join(" ") || sort_status.default
        const vb = titles[b][sort_status.by]?.join(" ") || sort_status.default
        if (va < vb) { return -1 * desc_adjust }
        else if (va > vb) { return 1 * desc_adjust }
        else { return 0 }
      })
      break
    default:
      entities = entities.sort((a,b) => {
        const va = sort_status.by === "key" ? a : (titles[a][sort_status.by] || sort_status.default)
        const vb = sort_status.by === "key" ? b: (titles[b][sort_status.by] || sort_status.default)
        if (va < vb) { return -1 * desc_adjust }
        else if (va > vb) { return 1 * desc_adjust }
        else { return 0 }
      })
  }
  for (const i of entities) {
    const tr = document.createElement("tr")
    const cover = document.createElement("td")
    const cover_img = document.createElement("img")
    let cover_src
    if (voice_library_dir && lwmp_server) {
      cover_src = titles[i].path.substring(voice_library_dir.length)
      if (cover_src[0] == "/") {
        cover_src = title_path.substring(1)
      }
      cover_src = [lwmp_server.replace(/\/$/, ""), "media", cover_src, (titles[i].imgpath || "thumb.jpg")].join("/")
    } else {
      cover_src = [titles[i].path, (titles[i].imgpath || "thumb.jpg")].join('/')
    }
    cover_img.src = cover_src.replace(/\?/g, "%3F").replace(/#/g, "%23")
    cover.appendChild(cover_img)
    tr.appendChild(cover)
    const title = document.createElement("td")
    const title_a = document.createElement("a")
    let title_path
    if (voice_library_dir && lwmp_server) {
      title_path = titles[i].path.substring(voice_library_dir.length)
      if (title_path[0] == "/") {
        title_path = title_path.substring(1)
      }
      title_path = [lwmp_server.replace(/\/$/, ""), title_path.replace(/\?/g, "%3F").replace(/#/g, "%23")].join("/?")
    } else {
      if (use_dlvfol) {
        title_path = "dlvfol://" + titles[i].path.replace(/\?/g, "%3F").replace(/#/g, "%23")
      } else {
        title_path = "file://" + titles[i].path.replace(/\?/g, "%3F").replace(/#/g, "%23")
      }
    }
    const title_text = document.createTextNode(i)
    title_a.appendChild(title_text)
    title_a.href = title_path
    title.appendChild(title_a)
    tr.appendChild(title)
    const circle = document.createElement("td")
    if (titles[i].circle) {circle.innerHTML = titles[i].circle}
    tr.appendChild(circle)
    const series = document.createElement("td")
    if (titles[i].series) {series.innerHTML = titles[i].series}
    tr.appendChild(series)
    const actress = document.createElement("td")
    if (titles[i].actress) {
      const actress_ul = document.createElement("ul")
      actress_ul.className = "inline_list"
      for (const j of titles[i].actress) {
        const li = document.createElement("li")
        li.className = "inline_list"
        const li_text = document.createTextNode(j)
        li.appendChild(li_text)
        actress_ul.appendChild(li)
      }
      actress.appendChild(actress_ul)
    }
    tr.appendChild(actress)
    const date = document.createElement("td")
    date.innerHTML = titles[i].btime
    tr.appendChild(date)
    const tags = document.createElement("td")
    if (titles[i].tags) {
      const tags_ul = document.createElement("ul")
      tags_ul.className = "inline_list"
      for (const j of titles[i].tags) {
        const li = document.createElement("li")
        li.className = "inline_list"
        const li_text = document.createTextNode(j)
        li.appendChild(li_text)
        tags_ul.appendChild(li)
      }
      tags.appendChild(tags_ul)
    }
    tr.appendChild(tags)
    const duration = document.createElement("td")
    duration.innerHTML = titles[i].duration || ""
    tr.appendChild(duration)
    const rate = document.createElement("td")
    if (!titles[i].rate) { titles[i].rate = 0 }
    rate.innerHTML = ("★".repeat(titles[i].rate) + "☆".repeat(5 - titles[i].rate))
    tr.appendChild(rate)
    const description = document.createElement("td")
    if (titles[i].description) {
      const description_body = document.createElement("span")
      description_body.title = titles[i].description
      description_body.appendChild(document.createTextNode("🗒"))
      description.appendChild(description_body)
    }
    tr.appendChild(description)
    const note = document.createElement("td")
    if (titles[i].note) {
      const note_ul = document.createElement("ul")
      for (const j of titles[i].note) {
        const li = document.createElement("li")
        const li_text = document.createTextNode(j)
        li.appendChild(li_text)
        note_ul.appendChild(li)
      }
      note.appendChild(note_ul)
    }
    tr.appendChild(note)
    const filelist = document.createElement("td")
    filelist.className = "filelist filelist_col"
    const filelist_ul = document.createElement("ul")
    for (const file of titles[i].filelist) {
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

sf.ResetBtn.addEventListener("click", function(e) {
  sf.reset()
  e.preventDefault()
  sort_status = {
    by: "btime",
    desc: false,
    type: null,
    default: "1970-01-01"
  }
  show(e)
})
