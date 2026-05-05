import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import '../styles/admin.css';

export default function Admin() {
  const [activePage, setActivePage] = useState('dashboard');
  const [noticias, setNoticias] = useState([]);

  useEffect(() => {
    fetch('/api/noticias').then(r => r.json()).then(setNoticias);
  }, []);

  return (
    <div className="admin-body">
      <aside className="sb" id="sb">
        <div className="sb-head">
          <div className="sb-logo-wrap"><span style={{fontSize:'20px'}}>🏛️</span></div>
          <div className="sb-ttl">
            <div className="t1">Vargem Grande</div>
            <div className="t2">Painel Administrativo</div>
          </div>
        </div>
        <nav className="sb-nav">
          <div className="grp-lbl">Visão Geral</div>
          <div className={`ni ${activePage === 'dashboard' ? 'act' : ''}`} onClick={() => setActivePage('dashboard')}>
            <span className="ni-ico">📊</span><span className="ni-lbl">Dashboard</span>
          </div>
          <div className="grp-lbl">Gestão Manual (Painel)</div>
          <div className={`ni ${activePage === 'noticias' ? 'act' : ''}`} onClick={() => setActivePage('noticias')}>
            <span className="ni-ico">📰</span><span className="ni-lbl">Notícias e Eventos</span>
          </div>
        </nav>
      </aside>
      <div className="main">
        <div className="topbar">
          <div className="tb-bc">
            <a href="/" target="_blank" style={{color: "var(--azul2)", textDecoration: "none"}}>Ver Portal Público ↗</a>
          </div>
        </div>
        <div className="content">
          {activePage === 'dashboard' && (
            <div>
              <div className="ph">
                <div><h1>Bem-vindo ao <em>Painel</em></h1><p>Prefeitura de Vargem Grande do Rio Pardo</p></div>
              </div>
              <div style={{color: "var(--txt)", background: "var(--bg2)", padding: "20px", borderRadius: "10px", marginTop: "20px"}}>
                <h3>Use o menu lateral para gerenciar as publicações.</h3>
              </div>
            </div>
          )}
          {activePage === 'noticias' && (
             <div>
               <div className="ph">
                 <div><h1>Gestao de <em>Noticias</em></h1></div>
                 <div className="ph-acts"><button className="btn btn-p" onClick={() => document.getElementById('mo-noticia')!.style.display = 'flex'}>✏️ Nova Noticia</button></div>
               </div>
               <div className="tw">
                 <div className="th"><div className="tt">Noticias</div></div>
                 <table>
                   <thead><tr><th>Titulo</th><th>Categoria</th><th>Data</th><th>Status</th><th>Acoes</th></tr></thead>
                   <tbody>
                     {noticias.map((n: any) => (
                       <tr key={n.id}>
                         <td><span className="tc">{n.titulo}</span></td>
                         <td>{n.categoria}</td>
                         <td>{n.data_pub}</td>
                         <td><span className="sp sp-ok">{n.status}</span></td>
                         <td>
                           <div style={{display:'flex',gap:'4px'}}>
                             <button className="btn btn-sm btn-d" onClick={async () => {
                               await fetch(`/api/noticias/${n.id}`, { method: 'DELETE' });
                               setNoticias(noticias.filter((x: any) => x.id !== n.id));
                             }}>🗑</button>
                           </div>
                         </td>
                       </tr>
                     ))}
                   </tbody>
                 </table>
               </div>
             </div>
          )}
        </div>
      </div>

      <div className="mo" id="mo-noticia" style={{display: 'none'}}>
        <div className="md">
          <div className="md-h"><h3>Nova Noticia</h3><button className="md-x" onClick={() => document.getElementById('mo-noticia')!.style.display = 'none'}>&times;</button></div>
          <div className="md-b">
            <form id="form-noticia" onSubmit={async (e) => {
              e.preventDefault();
              const fd = new FormData(e.target as HTMLFormElement);
              const data = Object.fromEntries(fd.entries());
              data.status = 'Publicada';
              data.autor = 'Admin';
              const res = await fetch('/api/noticias', {
                method: 'POST', headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(data)
              });
              const { id } = await res.json();
              data.id = id;
              setNoticias([data as any, ...noticias]);
              document.getElementById('mo-noticia')!.style.display = 'none';
              (e.target as HTMLFormElement).reset();
            }}>
              <div className="fg">
                <div className="fgrp span2"><label>Titulo</label><input name="titulo" className="fc" required/></div>
                <div className="fgrp"><label>Categoria</label><input name="categoria" className="fc" required/></div>
                <div className="fgrp"><label>Data</label><input name="data_pub" type="date" className="fc" required/></div>
                <div className="fgrp span2"><label>Resumo</label><textarea name="resumo" className="fc" required></textarea></div>
                <div className="fgrp span2"><label>Conteudo</label><textarea name="conteudo" className="fc" required></textarea></div>
              </div>
              <div className="md-f" style={{marginTop: "20px"}}>
                <button type="button" className="btn btn-s" onClick={() => document.getElementById('mo-noticia')!.style.display = 'none'}>Cancelar</button>
                <button type="submit" className="btn btn-p">Salvar</button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>
  );
}
