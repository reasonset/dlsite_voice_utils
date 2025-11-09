MAP = {
  "検索" => "Search",
  "タグ" => "Tags",
  "評価下限" => "Min rate",
  "出演者" => "Casts",
  "サークル" => "Circle",
  "長さ" => "Dur.",
  "キーワード" => "Keyword",
  "カバー" => "Art",
  "作品名" => "Title",
  "シリーズ" => "Series",
  "評価" => "Rate",
  "概要" => "🗒",
  "ノート" => "Notes",
  "ファイルリストを表示" => "Show file list",
  "ファイルリスト" => "File list",
  "音声作品Search" => "Search ASMR Titles"
}

html = File.read("index.html")

MAP.each do |k,v|
  html.gsub!(k, v)
end

File.open("index.en.html", "w") {|f| f.write html }