import renderHtml from './renderHtml';


export default {
  async fetch(request, env) {
    const { DATABASE } = env;
    const stmt = DATABASE.prepare('SELECT * FROM comments LIMIT 3');
    const { results } = await stmt.all();


    return new Response(
      renderHtml(JSON.stringify(results, null, 2)),
      { 
        headers: {
          'content-type': 'text/html'
        },
      }
    )
  }
}