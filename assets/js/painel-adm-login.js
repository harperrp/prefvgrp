(function () {
  "use strict";
  function css() {
    var s = document.createElement("style");
    s.textContent = ".vg-login{position:fixed;inset:0;z-index:12000;background:rgba(5,14,5,.96);display:flex;align-items:center;justify-content:center;padding:24px}.vg-login-card{width:min(420px,100%);background:#111711;border:1px solid #2a3a2a;border-radius:18px;box-shadow:0 24px 80px rgba(0,0,0,.7);padding:28px;color:#e2ebe2}.vg-login-card h2{font-size:24px;text-transform:uppercase;margin:0 0 6px}.vg-login-card h2 em{color:#2ecc40;font-style:normal}.vg-login-card p{color:#7a9a7a;font-size:13px;margin:0 0 20px}.vg-login-card label{display:block;color:#7a9a7a;font-size:11px;text-transform:uppercase;font-weight:800;letter-spacing:.8px;margin:12px 0 6px}.vg-login-card input{width:100%;background:#181f18;border:1px solid #2a3a2a;color:#e2ebe2;border-radius:10px;padding:13px;font:inherit}.vg-login-card button{width:100%;margin-top:18px;background:#1a7a1a;color:#fff;border:0;border-radius:10px;padding:13px;font-weight:900;cursor:pointer}.vg-login-card small{display:block;margin-top:14px;color:#4a6a4a;line-height:1.6}.vg-login-err{display:none;margin-top:12px;color:#f85149;font-size:12px}";
    document.head.appendChild(s);
  }
  function showLogin() {
    if (window.VGPortal.currentUser()) return;
    css();
    var wrap = document.createElement("div");
    wrap.className = "vg-login";
    wrap.innerHTML = '<form class="vg-login-card"><h2>Acesso ao <em>Painel</em></h2><p>Entre para editar o portal principal.</p><label>Usuário</label><input name="usuario" autocomplete="username" value="admin" required><label>Senha</label><input name="senha" type="password" autocomplete="current-password" value="admin123" required><button type="submit">Entrar no dashboard</button><div class="vg-login-err"></div><small>Primeiro acesso local: <strong>admin</strong> / <strong>admin123</strong>. Altere em Usuários e Permissões antes de publicar.</small></form>';
    document.body.appendChild(wrap);
    wrap.querySelector("form").addEventListener("submit", function (e) {
      e.preventDefault();
      var err = wrap.querySelector(".vg-login-err");
      window.VGPortal.login(this.usuario.value.trim(), this.senha.value).then(function () {
        wrap.remove();
        if (window.toast) toast("Login realizado com sucesso", "s");
      }).catch(function (ex) {
        err.style.display = "block";
        err.textContent = ex.message || "Falha ao autenticar";
      });
    });
  }
  document.addEventListener("DOMContentLoaded", showLogin);
  window.VGRequireLogin = showLogin;
})();
