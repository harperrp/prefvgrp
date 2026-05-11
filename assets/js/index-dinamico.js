(function () {
  "use strict";
  var E = function (s) { return window.VGPortal.escape(s); };
  function fmtDate(d) {
    if (!d) return "";
    if (/^\d{4}-\d{2}-\d{2}/.test(d)) return d.slice(0, 10).split("-").reverse().join("/");
    return d;
  }
  function firstTable(page) {
    return document.querySelector("#pg-" + page + " tbody");
  }
  function renderNoticias(state) {
    var list = (state.noticias || []).filter(function (n) { return n.status !== "Rascunho"; }).slice(0, 6);
    if (!list.length) return;
    var host = document.getElementById("vg-noticias-dinamicas");
    if (!host) {
      var faq = document.querySelector(".faq-list");
      if (!faq) return;
      var sec = document.createElement("div");
      sec.className = "sec reveal in";
      sec.id = "vg-noticias-dinamicas";
      sec.innerHTML = '<div class="wrap"><div class="shead"><div class="slbl">Atualizado pelo painel</div><div class="stit">Últimas <em>Notícias</em></div><div class="sdiv"></div></div><div class="sec-grid"></div></div>';
      faq.closest(".sec").parentNode.insertBefore(sec, faq.closest(".sec"));
      host = sec;
    }
    host.querySelector(".sec-grid").innerHTML = list.map(function (n) {
      return '<div class="card"><div class="ct">📰 ' + E(n.categoria || "Notícia") + '</div><h3 style="font-family:\'Barlow Condensed\';font-size:24px;text-transform:uppercase;margin:8px 0;color:var(--txt)">' + E(n.titulo) + '</h3><p style="font-size:13px;line-height:1.7;color:var(--txt2)">' + E(n.resumo || n.conteudo || "Publicação oficial.") + '</p><div style="margin-top:12px;font-size:11px;color:var(--g4);font-weight:700">' + E(n.data || "") + ' · ' + E(n.autor || "Admin") + '</div></div>';
    }).join("");
  }
  function renderTables(state) {
    var tb = firstTable("licitacoes");
    if (tb && (state.licitacoes || []).length) tb.innerHTML = state.licitacoes.map(function (l) {
      return '<tr><td><span class="mono tc" style="color:var(--g4);font-weight:700">' + E(l.numero) + '</span></td><td>' + E(l.objeto) + '</td><td>' + E(l.modalidade) + '</td><td class="mono">' + E(l.valor) + '</td><td>' + E(fmtDate(l.abertura)) + '</td><td><span class="sp sp-info">' + E(l.status || "Aberto") + '</span></td></tr>';
    }).join("");
    tb = firstTable("diarias");
    if (tb && (state.diarias || []).length) tb.innerHTML = state.diarias.map(function (d) {
      return '<tr><td><span class="tc">' + E(d.beneficiario || d.servidor) + '</span></td><td>' + E(d.destino) + '</td><td>' + E(d.objetivo) + '</td><td class="mono">' + E(d.valor) + '</td><td>' + E(fmtDate(d.data)) + '</td></tr>';
    }).join("");
    var leiBody = document.querySelector("#lei-table-pub tbody");
    if (leiBody && (state.leis || []).length) {
      window.LEIS_DATA = state.leis.map(function (l) { return {num:l.numero, tipo:l.tipo, data:l.data, ementa:l.ementa, sit:l.status || "Vigente", texto:l.texto || l.ementa, artigos:[]}; });
      leiBody.innerHTML = state.leis.map(function (l, i) {
        return '<tr data-tipo="' + E(l.tipo) + '" data-sit="' + E(l.status || "Vigente") + '"><td><span class="mono tc" style="color:var(--g4);font-weight:700">' + E(l.numero) + '</span></td><td><span style="font-size:11px;font-weight:700;color:var(--g4)">' + E(l.tipo) + '</span></td><td style="white-space:nowrap">' + E(fmtDate(l.data)) + '</td><td><span class="tc" style="font-size:12.5px">' + E(l.ementa) + '</span></td><td><span class="sp sp-ok">' + E(l.status || "Vigente") + '</span></td><td><button onclick="openLeiView(' + i + ')" style="display:flex;align-items:center;gap:5px;background:linear-gradient(135deg,#0d3b0d,#1a7a1a);color:#fff;border:none;padding:7px 14px;border-radius:6px;font-size:11px;font-weight:700;cursor:pointer;font-family:Barlow,sans-serif;white-space:nowrap">📄 Ver Lei</button></td></tr>';
      }).join("");
    }
  }
  function renderObras(state) {
    var grid = document.querySelector("#pg-obras .obras-grid");
    if (!grid || !(state.obras || []).length) return;
    grid.innerHTML = state.obras.map(function (o) {
      return '<div class="card"><div class="ct">🔧 ' + E(o.secretaria || "Obra") + '</div><h3 style="font-family:\'Barlow Condensed\';font-size:24px;text-transform:uppercase;margin:8px 0;color:var(--txt)">' + E(o.nome) + '</h3><p style="font-size:13px;color:var(--txt2);line-height:1.7">' + E(o.descricao || "Obra pública cadastrada no painel.") + '</p><div class="pw" style="margin-top:14px"><div class="prow"><span class="pl">Execução física</span><span class="pv" style="color:var(--g4)">' + E(o.progresso || 0) + '%</span></div><div class="pt"><div class="pf" style="width:' + E(o.progresso || 0) + '%;background:var(--g4)"></div></div></div><div style="font-size:12px;color:var(--txt2);margin-top:12px">' + E(o.valor || "") + ' · ' + E(o.status || "") + '</div></div>';
    }).join("");
  }
  function wireSearch() {
    var btn = document.querySelector(".srch button");
    var input = document.getElementById("searchInput");
    if (btn && input) btn.onclick = function () {
      var q = input.value.toLowerCase();
      if (/licita|edital|contrato/.test(q)) navTo("licitacoes");
      else if (/lei|decreto|portaria|legis/.test(q)) navTo("legislacao");
      else if (/obra|pavimenta/.test(q)) navTo("obras");
      else if (/di.ria|viagem/.test(q)) navTo("diarias");
      else if (/ouvid|sic|pedido|inform/.test(q)) navTo("ouvidoria");
      else navTo("transparencia");
    };
  }
  function render(state) { renderNoticias(state); renderTables(state); renderObras(state); wireSearch(); }
  document.addEventListener("DOMContentLoaded", function () { window.VGPortal.load().then(render); });
  window.addEventListener("vg:data", function (e) { render(e.detail); });
})();
