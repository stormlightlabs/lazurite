import { getCollection } from "astro:content";

const redirectPage = (href: string) => `<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta http-equiv="refresh" content="0; url=${href}" />
    <link rel="canonical" href="${href}" />
    <title>Redirecting...</title>
  </head>
  <body>
    <p>Redirecting to <a href="${href}">${href}</a>.</p>
  </body>
</html>`;

export async function getStaticPaths() {
  const pages = await getCollection("legalPages");

  return pages.map((page) => ({
    params: { slug: page.data.slug },
    props: { href: `/${page.data.slug}` },
  }));
}

export function GET({ props }: { props: { href: string } }) {
  return new Response(redirectPage(props.href), {
    headers: {
      "Content-Type": "text/html; charset=utf-8",
    },
  });
}
