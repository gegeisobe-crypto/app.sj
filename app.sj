import express from 'express';
import cors from 'cors';
const app = express();
app.use(cors({origin:'*'}));
app.use(express.json());
const CLIENT_ID = process.env.LIVEPIX_CLIENT_ID;
const CLIENT_SECRET = process.env.LIVEPIX_CLIENT_SECRET;
app.get('/', (req,res)=>{ res.json({status:'Flappy Gateway OK - Render LIVEPIX R$10-1000'}); });
app.post('/criar-pix', async (req,res)=>{
  const {valor, userId} = req.body;
  if(!valor || valor < 10 || valor > 1000) return res.status(400).json({erro:'Use 10 a 1000'});
  try{
    const auth = await fetch('https://api.livepix.gg/oauth/token',{
      method:'POST', headers:{'Content-Type':'application/json'},
      body: JSON.stringify({client_id:CLIENT_ID, client_secret:CLIENT_SECRET, grant_type:'client_credentials'})
    }).then(r=>r.json());
    const token = auth.access_token;
    const pix = await fetch('https://api.livepix.gg/api/v1/pix/qrcode',{
      method:'POST',
      headers:{'Authorization':`Bearer ${token}`, 'Content-Type':'application/json'},
      body: JSON.stringify({amount:Math.round(valor*100), message:`Flappy:${userId}:${valor}`, expiresIn:900})
    }).then(r=>r.json());
    res.json({qrcode: pix.qrCode, imagem: pix.brCodeBase64, id: pix.id, valor});
  }catch(e){ res.status(500).json({erro:e.message}); }
});
app.post('/webhook-livepix', (req,res)=>{ console.log('PAGOU',req.body); res.json({ok:true}); });
app.listen(process.env.PORT||10000, ()=> console.log('Rodando'));
