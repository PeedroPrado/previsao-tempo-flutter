
const http = require('http');

const PORT = 3001;
const CPTEC = 'http://servicos.cptec.inpe.br/XML';

const server = http.createServer(async (req, res) => {
  // Libera acesso do Flutter Web durante o desenvolvimento
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    return res.end();
  }

  try {
    const url = new URL(req.url, `http://localhost:${PORT}`);
    let destino;

    // Busca de cidades
    if (url.pathname === '/api/cidades') {
      const cidade = url.searchParams.get('city');

      if (!cidade) {
        res.writeHead(400);
        return res.end('Informe o nome da cidade.');
      }

      destino = `${CPTEC}/listaCidades?city=${encodeURIComponent(cidade)}`;
    }

    // Previsão de 4 dias
    else if (url.pathname === '/api/previsao') {
      const id = url.searchParams.get('id');

      if (!id) {
        res.writeHead(400);
        return res.end('Informe o ID da cidade.');
      }

      destino = `${CPTEC}/cidade/${encodeURIComponent(id)}/previsao.xml`;
    }

    else {
      res.writeHead(404);
      return res.end('Rota não encontrada.');
    }

    const resposta = await fetch(destino);

    const bytes = await resposta.arrayBuffer();
  const conteudo = new TextDecoder('windows-1252').decode(bytes);

    res.writeHead(resposta.status, {
      'Content-Type': 'application/xml; charset=utf-8',
    });

    res.end(conteudo);

  } catch (erro) {
    console.error('Erro no proxy:', erro);

    res.writeHead(500, {
      'Content-Type': 'text/plain; charset=utf-8',
    });

    res.end('Erro ao consultar o serviço CPTEC.');
  }
});

server.listen(PORT, () => {
  console.log(`Proxy CPTEC rodando em http://localhost:${PORT}`);
});
