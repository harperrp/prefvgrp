(function () {
  "use strict";
  var E = function (s) { return window.VGPortal.escape(s); };
  function val(modal, label) {
    var labels = Array.prototype.slice.call(modal.querySelectorAll("label"));
    var found = labels.find(function (l) { return l.textContent.toLowerCase().indexOf(label.toLowerCase()) >= 0; });
    if (!found) return "";
    var field = found.parentElement.querySelector("input,textarea,select");
    return field ? field.value.trim() : "";
  }
  function tableBody(page) {
    var el = document.querySelector("#page-" + page + " tbody");
    return el;
  }
  function actions(module, id) {
    return '<div style="display:flex;gap:4px"><button class="btn btn-sm btn-s" onclick="openMo(\'mo-' + (module === 'licitacoes' ? 'licit' : module === 'leis' ? 'lei' : module === 'documentos' ? 'doc' : module.slice(0,-1)) + '\')">✏️</button><button class="btn btn-sm btn-d" data-vg-module="' + module + '" data-vg-id="' + id + '">🗑</button></div>';
  }
  function render(state) {
    var tb = tableBody("noticias");
    if (tb) tb.innerHTML = (state.noticias || []).map(function (n) {
      return '<tr data-vg-id="' + E(n.id) + '"><td><span class="tc">' + E(n.titulo) + '</span></td><td>' + E(n.categoria || "Geral") + '</td><td>' + E(n.autor || "Admin") + '</td><td>' + E(n.data || "") + '</td><td><span class="sp ' + (n.status === "Rascunho" ? "sp-pend" : "sp-ok") + '">' + E(n.status || "Publicada") + '</span></td><td>' + actions("noticias", n.id) + '</td></tr>';
    }).join("");
    tb = tableBody("licitacoes");
    if (tb) tb.innerHTML = (state.licitacoes || []).map(function (l) {
      return '<tr data-vg-id="' + E(l.id) + '"><td><span class="mono tc" style="color:var(--g5)">' + E(l.numero) + '</span></td><td>' + E(l.objeto) + '</td><td>' + E(l.modalidade) + '</td><td class="mono">' + E(l.valor) + '</td><td>' + E(l.abertura) + '</td><td><span class="sp sp-info">' + E(l.status || "Aberto") + '</span></td><td>' + actions("licitacoes", l.id) + '</td></tr>';
    }).join("");
    tb = tableBody("obras");
    if (tb) tb.innerHTML = (state.obras || []).map(function (o) {
      return '<tr data-vg-id="' + E(o.id) + '"><td><span class="tc">' + E(o.nome) + '</span></td><td>' + E(o.secretaria) + '</td><td class="mono">' + E(o.valor) + '</td><td>' + E(o.status) + '</td><td>' + E(o.progresso || 0) + '%</td><td>' + actions("obras", o.id) + '</td></tr>';
    }).join("");
    document.querySelectorAll(".sc-num").forEach(function (el, i) {
      if (i === 0) el.textContent = (state.noticias || []).length;
      if (i === 1) el.textContent = (state.licitacoes || []).length;
      if (i === 3) el.textContent = (state.leis || []).length || el.textContent;
    });
  }
  function saveFromModal(id) {
    var m = document.getElementById(id); if (!m) return null;
    if (id === "mo-noticia") return window.VGPortal.create("noticias", {titulo:val(m,"Título") || val(m,"Titulo") || "Nova notícia", categoria:val(m,"Categoria") || "Geral", autor:"Admin", data:window.VGPortal.todayBR(), status:(val(m,"Publicacao").toLowerCase().indexOf("rascunho") >= 0 ? "Rascunho" : "Publicada"), resumo:val(m,"Resumo"), conteudo:val(m,"Conteudo") || val(m,"Conteúdo")});
    if (id === "mo-licit") return window.VGPortal.create("licitacoes", {numero:val(m,"Numero") || val(m,"Número") || "Novo", modalidade:val(m,"Modalidade") || "Pregão Eletrônico", objeto:val(m,"Objeto") || "Processo licitatório", valor:val(m,"Valor") || "R$ 0,00", abertura:val(m,"Abertura"), status:val(m,"Status") || "Aberto", justificativa:val(m,"Justificativa")});
    if (id === "mo-obra") return window.VGPortal.create("obras", {nome:val(m,"Nome") || "Nova obra", secretaria:val(m,"Secretaria"), valor:val(m,"Valor") || "R$ 0,00", inicio:val(m,"Inicio") || val(m,"Início"), previsao:val(m,"Previsao") || val(m,"Previsão"), descricao:val(m,"Descricao") || val(m,"Descrição"), progresso:val(m,"Execucao") || val(m,"Execução") || 0, status:val(m,"Status") || "Em andamento"});
    if (id === "mo-diaria") return window.VGPortal.create("diarias", {beneficiario:val(m,"Beneficiario") || val(m,"Servidor") || "Servidor", destino:val(m,"Destino"), valor:val(m,"Valor") || "R$ 0,00", data:window.VGPortal.todayBR(), objetivo:val(m,"Objetivo")});
    if (id === "mo-doc") return window.VGPortal.create("documentos", {titulo:val(m,"Titulo") || val(m,"Título") || "Documento", categoria:val(m,"Categoria"), data:window.VGPortal.todayBR(), descricao:val(m,"Descricao") || val(m,"Descrição")});
    if (id === "mo-lei") return window.VGPortal.create("leis", {tipo:val(m,"Tipo") || "Lei", numero:val(m,"Numero") || val(m,"Número") || "S/N", ementa:val(m,"Ementa") || val(m,"Resumo") || "Legislação municipal", data:window.VGPortal.todayBR(), status:"Vigente", texto:val(m,"Texto")});
    return null;
  }
  document.addEventListener("click", function (e) {
    var delBtn = e.target.closest("[data-vg-module][data-vg-id]");
    if (delBtn) {
      window.VGPortal.remove(delBtn.dataset.vgModule, delBtn.dataset.vgId).then(function () { return window.VGPortal.load(); }).then(render);
      if (window.toast) toast("Registro excluído", "s");
      return;
    }
    var modal = e.target.closest(".mo");
    if (!modal) return;
    var btn = e.target.closest("button.btn-p");
    if (!btn) return;
    var saved = saveFromModal(modal.id);
    if (saved) saved.then(function () { return window.VGPortal.load(); }).then(render).then(function () { if (window.toast) toast("Salvo e publicado no portal", "s"); });
  }, true);
  document.addEventListener("DOMContentLoaded", function () {
    window.VGPortal.load().then(render);
    var portal = document.querySelector('[title="Ver portal público"]');
    if (portal) portal.onclick = function () { window.open("index.html", "_blank"); };
    var sair = document.querySelector('[title="Sair"]');
    if (sair) sair.onclick = function () { window.VGPortal.logout().then(function () { location.reload(); }); };
  });
  window.addEventListener("vg:data", function (e) { render(e.detail); });
})();
