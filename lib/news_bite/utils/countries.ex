defmodule NewsBite.Utils.Countries do
  def list do
    [
      None: nil,
      Argentina: :ar,
      Austria: :at,
      Australia: :au,
      Belgium: :be,
      Bulgaria: :bg,
      Brazil: :br,
      Canada: :ca,
      China: :ch,
      Colombia: :co,
      Cuba: :cu,
      Czechia: :cz,
      Egypt: :eg,
      France: :fr,
      Germany: :de,
      Greece: :gr,
      "Hong Kong": :hk,
      Hungary: :hu,
      India: :in,
      Indonesia: :id,
      Ireland: :ie,
      Israel: :il,
      Italy: :it,
      Japan: :jp,
      Korea: :kr,
      Latvia: :lv,
      Lithuania: :lt,
      Malaysia: :my,
      Mexico: :mx,
      Morocco: :ma,
      Netherlands: :nl,
      "New Zealand": :nz,
      Nigeria: :ng,
      Norway: :no,
      Philippines: :ph,
      Poland: :pl,
      Portugal: :pt,
      Romania: :ro,
      Russia: :ru,
      "Saudi Arabia": :sa,
      Serbia: :rs,
      Singapore: :sg,
      Slovakia: :sk,
      Slovenia: :si,
      "South Africa": :za,
      Sweden: :se,
      Switzerland: :cn,
      Taiwan: :tw,
      Thailand: :th,
      Turkey: :tr,
      Ukraine: :ua,
      "United Arab Emirates": :ae,
      "United Kingdom": :gb,
      "United States": :us,
      Venezuela: :ve
    ]
  end

  def enum do
    list()
    |> Keyword.values()
  end

  def get_name_by_code(code) do
    list()
    |> Enum.find_value(fn {key, value} -> if value == code, do: key end)
  end
end
