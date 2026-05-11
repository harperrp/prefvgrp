(function (window) {
  "use strict";

  var STORE_KEY = "vg_portal_state_v1";
  var AUTH_KEY = "vg_portal_auth_v1";
  var API_URL = (window.VG_API_URL || "api/index.php");

  function uid(prefix) {
    return (prefix || "id") + "_" + Date.now().toString(36) + Math.random().toString(36).slice(2, 8);
  }

  function todayBR() {
    return new Date().toLocaleDateString("pt-BR");
  }

  function seed() {
    return {
      noticias: [
        {id:"not_1", titulo:"Portal da Transparência atualizado — LAI 12.527/2011", categoria:"Transparência", autor:"Admin", data:"30/04/2025", status:"Publicada", resumo:"Portal atualizado com dados da LAI e atalhos de acesso ao cidadão.", conteudo:"Publicação oficial do portal municipal.", imagem:""},
        {id:"not_2", titulo:"Obra de pavimentação no Bairro Centro", categoria:"Obras", autor:"Comunicação", data:"25/04/2025", status:"Publicada", resumo:"Frentes de pavimentação avançam no perímetro urbano.", conteudo:"A Prefeitura informa o andamento da obra.", imagem:""},
        {id:"not_3", titulo:"Concurso Público 2025 — Gabarito divulgado", categoria:"RH", autor:"RH", data:"22/04/2025", status:"Rascunho", resumo:"Material em conferência pela comissão organizadora.", conteudo:"Rascunho administrativo.", imagem:""}
      ],
      licitacoes: [
        {id:"lic_1", numero:"012/2025", objeto:"Aquisição de medicamentos — Farmácia Básica", modalidade:"Pregão Eletrônico", valor:"R$ 380.000", abertura:"15/05/2025", status:"Aberto", justificativa:"Atender a rede municipal de saúde."},
        {id:"lic_2", numero:"011/2025", objeto:"Reforma do Ginásio Municipal", modalidade:"Concorrência", valor:"R$ 920.000", abertura:"08/05/2025", status:"Aberto", justificativa:"Melhoria da infraestrutura esportiva."}
      ],
      diarias: [],
      leis: [],
      obras: [
        {id:"obr_1", nome:"Reforma UBS Central", secretaria:"Saúde", valor:"R$ 145.000", inicio:"2025-01-15", previsao:"2025-07-30", descricao:"Reforma e adequação da unidade.", progresso:72, status:"Em andamento"}
      ],
      documentos: [],
      faq: [],
      enquetes: [],
      ouvidoria: [],
      redirects: {
        transparencia:"https://portaldatransparencia.gov.br",
        portalFederal:"https://www.gov.br/",
        esus:"https://sisaps.saude.gov.br/esus/",
        diario:"#diario-oficial",
        contato:"#contato"
      },
      users: [{id:"usr_1", nome:"Administrador", usuario:"admin", senha:"admin123", perfil:"Administrador"}],
      config: {municipio:"Prefeitura de Vargem Grande do Rio Pardo", uf:"MG"},
      updatedAt: new Date().toISOString()
    };
  }

  function loadLocal() {
    try {
      var raw = localStorage.getItem(STORE_KEY);
      if (!raw) {
        var s = seed();
        localStorage.setItem(STORE_KEY, JSON.stringify(s));
        return s;
      }
      var data = JSON.parse(raw);
      var base = seed();
      Object.keys(base).forEach(function (k) { if (typeof data[k] === "undefined") data[k] = base[k]; });
      return data;
    } catch (e) { return seed(); }
  }

  function saveLocal(data) {
    data.updatedAt = new Date().toISOString();
    localStorage.setItem(STORE_KEY, JSON.stringify(data));
    window.dispatchEvent(new CustomEvent("vg:data", {detail:data}));
    return data;
  }

  function request(action, payload) {
    return fetch(API_URL + "?action=" + encodeURIComponent(action), {
      method: "POST",
      credentials: "same-origin",
      headers: {"Content-Type":"application/json"},
      body: JSON.stringify(payload || {})
    }).then(function (r) {
      if (!r.ok) throw new Error("HTTP " + r.status);
      return r.json();
    }).then(function (json) {
      if (!json.ok) throw new Error(json.error || "Falha na API");
      return json.data;
    });
  }

  function listLocal(module) {
    var data = loadLocal();
    return data[module] || [];
  }

  var VG = {
    uid: uid,
    todayBR: todayBR,
    storeKey: STORE_KEY,
    load: function () {
      return request("state").then(function (remote) {
        if (remote && typeof remote === "object") saveLocal(Object.assign(loadLocal(), remote));
        return loadLocal();
      }).catch(loadLocal);
    },
    saveState: function (state) {
      saveLocal(state);
      return request("sync", state).catch(function () { return state; });
    },
    list: function (module) {
      return request("list", {module:module}).catch(function () { return listLocal(module); });
    },
    create: function (module, item) {
      item.id = item.id || uid(module.slice(0, 3));
      item.createdAt = item.createdAt || new Date().toISOString();
      var data = loadLocal();
      data[module] = data[module] || [];
      data[module].unshift(item);
      saveLocal(data);
      return request("create", {module:module, item:item}).catch(function () { return item; });
    },
    update: function (module, id, patch) {
      var data = loadLocal();
      data[module] = (data[module] || []).map(function (it) { return it.id === id ? Object.assign({}, it, patch, {updatedAt:new Date().toISOString()}) : it; });
      saveLocal(data);
      return request("update", {module:module, id:id, item:patch}).catch(function () { return patch; });
    },
    remove: function (module, id) {
      var data = loadLocal();
      data[module] = (data[module] || []).filter(function (it) { return it.id !== id; });
      saveLocal(data);
      return request("delete", {module:module, id:id}).catch(function () { return true; });
    },
    login: function (usuario, senha) {
      return request("login", {usuario:usuario, senha:senha}).then(function (user) {
        sessionStorage.setItem(AUTH_KEY, JSON.stringify(user));
        return user;
      }).catch(function () {
        var users = loadLocal().users || [];
        var user = users.find(function (u) { return u.usuario === usuario && u.senha === senha; });
        if (!user) throw new Error("Usuário ou senha inválidos");
        sessionStorage.setItem(AUTH_KEY, JSON.stringify({id:user.id, nome:user.nome, usuario:user.usuario, perfil:user.perfil}));
        return user;
      });
    },
    logout: function () {
      sessionStorage.removeItem(AUTH_KEY);
      return request("logout").catch(function () { return true; });
    },
    currentUser: function () {
      try { return JSON.parse(sessionStorage.getItem(AUTH_KEY) || "null"); } catch (e) { return null; }
    },
    escape: function (s) {
      return String(s == null ? "" : s).replace(/[&<>'"]/g, function (c) { return {"&":"&amp;","<":"&lt;",">":"&gt;","'":"&#39;",'"':"&quot;"}[c]; });
    }
  };

  window.VGPortal = VG;
})(window);
