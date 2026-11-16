from pathlib import Path
from html import escape
P=Path(__file__).resolve().parents[1]
# Leer los 35 nombres e información desde el mismo módulo generador sin reconstruir seed.
ns={'__file__':str(P/'scripts'/'generate_seed.py')}
source=(P/'scripts'/'generate_seed.py').read_text(encoding='utf8')
exec(source,ns)
products=ns['products']
palette={'base':('#ded6c0','#5d5940'),'sabor':('#e9bdac','#6b4033'),'suplemento':('#d8c8b1','#635443'),'fibra':('#cbd6bd','#486041'),'pack':('#e3cfbe','#765442')}
for i,(name,desc,cat,price,stock,origin) in enumerate(products,1):
    back,ink=palette[cat]
    label=escape(name.replace('Kit ','').replace('Complemento ','').replace('Sabor ','').replace('Fibra ','').replace('Pack ','')[:24])
    svg=(f'<svg xmlns="http://www.w3.org/2000/svg" width="760" height="570" viewBox="0 0 760 570"><defs><linearGradient id="bg" x1="0" y1="0" x2="1" y2="1"><stop stop-color="#f7f2eb"/><stop offset="1" stop-color="{back}"/></linearGradient><linearGradient id="foil" x1="0" y1="0" x2="1" y2="1"><stop stop-color="{ink}"/><stop offset="1" stop-color="#302a23"/></linearGradient><filter id="shadow" x="-40%" y="-40%" width="180%" height="180%"><feGaussianBlur stdDeviation="20"/></filter></defs>'
    '<rect width="760" height="570" fill="url(#bg)"/><ellipse cx="390" cy="486" rx="170" ry="25" fill="#513b31" opacity=".20" filter="url(#shadow)"/>'
    '<path d="M272 70 L488 70 L510 473 Q503 495 485 495 H270 Q252 494 251 474Z" fill="url(#foil)"/><path d="M271 69 H489 L491 99 H268Z" fill="#a69886" opacity=".45"/><path d="M267 474H491" stroke="#bfb4a4" stroke-width="7"/>'
    '<path d="M297 132H461" stroke="#ffffff" stroke-opacity=".20"/><text x="380" y="215" font-family="Arial,sans-serif" font-size="53" letter-spacing="-3" font-weight="bold" text-anchor="middle" fill="#f7f0e6">crafted</text><path d="M378 246 Q350 278 372 300 Q398 289 378 246 M378 280 Q399 257 417 268 Q409 296 378 293" stroke="#d7dbc7" fill="none" stroke-width="3.8"/>'
    f'<text x="380" y="353" font-family="Arial,sans-serif" font-size="21" font-weight="bold" text-anchor="middle" fill="#ffffff">{label}</text>'
    f'<text x="380" y="387" font-family="Arial,sans-serif" font-size="15" letter-spacing="3" text-anchor="middle" fill="#f7f0e6">{cat.upper()}</text>'
    f'<rect x="326" y="420" rx="4" width="108" height="26" fill="{back}"/><text x="380" y="438" font-family="Arial,sans-serif" font-weight="bold" font-size="13" text-anchor="middle" fill="#302a23">CRAFTED DEMO</text></svg>')
    (P/'assets'/'img'/f'product_{i:02d}.svg').write_text(svg,encoding='utf8')
print(f'Generadas {len(products)} imágenes ilustrativas distintas')
