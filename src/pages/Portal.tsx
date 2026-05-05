import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import '../styles/portal.css';

export default function Portal() {
  const [activeTab, setActiveTab] = useState('home');
  const [noticias, setNoticias] = useState([]);
  const [licitacoes, setLicitacoes] = useState([]);
  const [obras, setObras] = useState([]);

  useEffect(() => {
    fetch('/api/noticias').then(r => r.json()).then(setNoticias);
    fetch('/api/licencas').then(r => r.json()).then(setLicitacoes);
    fetch('/api/obras').then(r => r.json()).then(setObras);
  }, []);

  return (
    <div>
      <div className="topbar">
        <div className="tb-in">
          <div className="tbn">
            <Link to="/admin" style={{color: '#2ecc40', fontWeight: 'bold'}}>🔒 Painel Admin</Link>
          </div>
        </div>
      </div>
      <nav className="mainnav">
        <div className="mn-in">
          <div className="mn-logo"><h2 style={{color:'white'}}>PREF. VARGEM GRANDE</h2></div>
          <div className="mnl">
            <a className={activeTab === 'home' ? 'act' : ''} onClick={() => setActiveTab('home')}>Início</a>
            <a className={activeTab === 'licitacoes' ? 'act' : ''} onClick={() => setActiveTab('licitacoes')}>Licitações</a>
            <a className={activeTab === 'obras' ? 'act' : ''} onClick={() => setActiveTab('obras')}>Obras</a>
          </div>
        </div>
      </nav>

      {activeTab === 'home' && (
        <>
          <div className="hero">
            <div className="hcont">
              <div className="hleft">
                <div className="hh1">Prefeitura de <em>Vargem Grande</em></div>
                <h3 style={{color:'white'}}>do Rio Pardo &middot; Minas Gerais</h3>
              </div>
            </div>
          </div>

          <div className="stats">
            <div className="sts-in">
              <span className="st" onClick={() => setActiveTab('licitacoes')}><div><strong>{licitacoes.length}</strong> Licitações</div></span>
              <span className="st" onClick={() => setActiveTab('obras')}><div><strong>{obras.length}</strong> Obras em andamento</div></span>
            </div>
          </div>

          <div className="sec wrap">
            <div className="stit">Últimas <em>Notícias</em></div>
            <div className="ngrid" style={{marginTop: '20px'}}>
              {noticias[0] && (
                <div className="nfeat">
                  <div className="ntit">{noticias[0].titulo}</div>
                  <div style={{color:'green', fontSize:'12px', marginBottom:'10px'}}>{noticias[0].data_pub} - {noticias[0].categoria}</div>
                  <div>{noticias[0].resumo}</div>
                </div>
              )}
              <div className="nside">
                {noticias.slice(1).map((n: any) => (
                  <div className="nsm" key={n.id}>
                     <div className="nsmtt">{n.titulo}</div>
                     <div style={{fontSize:'11px', color:'gray', marginTop:'5px'}}>{n.data_pub}</div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </>
      )}

      {activeTab === 'licitacoes' && (
        <div className="wrap">
          <div className="dtw">
            <div className="dth"><div className="dtlbl">Processos Licitatórios</div></div>
            <table>
              <thead><tr><th>Nº Processo</th><th>Objeto</th><th>Modalidade</th><th>Valor</th><th>Status</th></tr></thead>
              <tbody>
                {licitacoes.map((l: any) => (
                  <tr key={l.id}>
                    <td style={{color:'green', fontWeight:'bold'}}>{l.processo}</td>
                    <td>{l.objeto}</td>
                    <td>{l.modalidade}</td>
                    <td>{l.valor}</td>
                    <td>{l.status}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {activeTab === 'obras' && (
        <div className="wrap">
          <div className="obras-grid">
            {obras.map((o: any) => (
              <div className="oc" key={o.id}>
                <div className="oc-nome">{o.nome}</div>
                <div style={{fontSize:'12px', color:'blue', marginBottom:'5px'}}>{o.status} - {o.progresso}%</div>
                <div className="oc-desc">{o.descricao}</div>
                <div style={{fontSize:'12px'}}><strong>Secretaria:</strong> {o.secretaria}</div>
                <div style={{fontSize:'12px', color:'green'}}><strong>Valor:</strong> {o.valor}</div>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
