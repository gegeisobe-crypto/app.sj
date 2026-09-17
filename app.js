import express from 'express';
import cors from 'cors';
const app = express();
app.use(cors({origin:'*'}));
app.use(express.json());
app.get('/', (req,res)=> res.json({ok:true, msg:'Flappy Gateway R$10-1000 LIVE'}));
app.post('/criar-pix', async (req,res)=>{
  const {valor, userId} = req.body;
  try{
    const CLIENT_ID = process.env.LIVEPIX_CLIENT_ID;
    const CLIENT_SECRET = process.env.LIVEPIX_CLIENT_SECRET;
    const auth = await fetch('https://api.livepix.gg/oauth/token',{method:'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify({client_id:CLIENT_ID, client_secret:CLIENT_SECRET, grant_type:'client_credentials'})}).then(r=>r.json());
    const token = auth.access_token;
    const pix = await fetch('https://api.livepix.gg/api/v1/pix/qrcode',{method:'POST', headers:{'Authorization':`Bearer ${token}`, 'Content-Type':'application/json'}, body: JSON.stringify({amount:Math.round(valor*100), message:`Flappy:${userId}`, expiresIn:900})}).then(r=>r.json());
    res.json({qrcode: pix.qrCode, imagem: pix.brCodeBase64, id: pix.id});
  }catch(e){ res.status(500).json({erro:e.message}); }
});
app.listen(process.env.PORT||10000);
