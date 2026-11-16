from pathlib import Path
P=Path(__file__).resolve().parents[1]
base=[
('Proteína de suero (Whey)','Proteína láctea para complementar la ingesta diaria','México',1.12,25,1,'Contiene leche'),
('Aislado de suero','Proteína láctea concentrada, con menos lactosa que el concentrado','Estados Unidos',1.45,25,1,'Contiene leche'),
('Proteína de chícharo','Alternativa proteica de origen vegetal','Canadá',1.10,25,1,'Consultar fabricante'),
('Proteína de arroz','Alternativa vegetal elaborada a partir de arroz','México',1.04,25,1,'Consultar fabricante'),
('Proteína de soya','Proteína vegetal de alta calidad','México',.92,25,1,'Contiene soya'),
('Mezcla vegetal','Combinación de proteínas vegetales','México',1.16,25,1,'Consultar fabricante'),
]
sabores=[('Chocolate',.40),('Vainilla',.32),('Fresa',.34),('Plátano',.32),('Café',.36),('Canela',.31),('Cacao intenso',.44),('Frutos rojos',.41)]
sups=[
('Creatina monohidratada','Ingrediente utilizado en nutrición deportiva; consultar evidencia y precauciones',.65,0.5,5,1),
('Vitamina B12','Micronutriente que interviene en funciones metabólicas',1750,0.000001,0.0000024,1),
('Vitamina C','Vitamina hidrosoluble para complementar la dieta',.55,0.01,0.1,1),
('Vitamina D3','Micronutriente liposoluble; requiere revisión de ingesta total',8500,0.000005,0.00002,1),
('Magnesio','Mineral esencial en diversas funciones del organismo; la forma química importa',.65,0.05,0.15,1),
('Zinc','Mineral esencial; requiere revisar otras fuentes de ingesta',1.2,0.002,0.01,1),
('Cacao natural','Ingrediente botánico de cacao sin afirmación orgánica automática',.35,0.5,4,1),
('Espirulina','Biomasa de cianobacterias para uso alimentario de calidad verificada',.55,0.2,2,1),
('Maca en polvo','Ingrediente de origen vegetal; beneficios no garantizados',.50,0.3,3,1),
('Matcha','Té verde molido; contiene cafeína',1.15,0.2,1.5,1),
]
fibras=[
('Inulina',.45,.5,4,1),('Psyllium',.48,.5,4,1),('Fibra de avena',.29,.5,5,1),('Fibra de acacia',.47,.5,4,1),('Linaza molida',.24,.5,5,1),('Chía molida',.38,.5,5,1),('Fibra de manzana',.38,.5,4,1)]
pres=[('Polvo · 15 porciones','polvo',15,90,'Bolsa resellable; 15 porciones de demostración'),('Polvo · 30 porciones','polvo',30,150,'Bolsa resellable; 30 porciones de demostración'),('Barritas · 6 piezas','barrita',6,130,'Caja con seis barritas de demostración'),('Barritas · 12 piezas','barrita',12,230,'Caja con doce barritas de demostración')]
def quote(s): return "'"+str(s).replace("'","''")+"'"
seed=['USE crafted;','-- Datos demostrativos, precios e inventarios ficticios.','-- IMPORTANTE: ninguna certificación orgánica es afirmada sin evidencia.']
for i,(name,desc,origin,cost,grams,bar,allergen) in enumerate(base):
 img='assets/img/base.svg';
 seed.append(f"INSERT INTO ingredientes(nombre,categoria,descripcion,beneficios,origen,fabricante,foto,organico_certificado,alergenos,precio_por_gramo,stock_gramos,minimo_g,maximo_g,admite_barrita) VALUES({quote(name)},'base',{quote(desc)},'Contribuye a la ingesta diaria de proteína',{quote(origin)},'Proveedor demostrativo',{quote(img)},0,{quote(allergen)},{cost},45000,{grams},{grams},{bar});")
for name,cost in sabores:
 seed.append(f"INSERT INTO ingredientes(nombre,categoria,descripcion,beneficios,origen,fabricante,foto,organico_certificado,alergenos,precio_por_gramo,stock_gramos,minimo_g,maximo_g,admite_barrita) VALUES({quote(name)},'sabor',{quote('Saborizante alimentario de '+name.lower()+'; verificar composición con proveedor')},'Personaliza el sabor de la fórmula','México','Proveedor demostrativo','assets/img/sabor.svg',0,'Consultar fabricante',{cost},30000,2,2,1);")
for name,desc,cost,mini,maxi,bar in sups:
 seed.append(f"INSERT INTO ingredientes(nombre,categoria,descripcion,beneficios,origen,fabricante,foto,organico_certificado,alergenos,precio_por_gramo,stock_gramos,minimo_g,maximo_g,admite_barrita) VALUES({quote(name)},'suplemento',{quote(desc)},{quote('Descripción educativa; no sustituye evaluación profesional')},'Por verificar','Proveedor demostrativo','assets/img/suplemento.svg',0,'Consultar fabricante',{cost},12000,{mini:.8f},{maxi:.8f},{bar});")
for name,cost,mini,maxi,bar in fibras:
 seed.append(f"INSERT INTO ingredientes(nombre,categoria,descripcion,beneficios,origen,fabricante,foto,organico_certificado,alergenos,precio_por_gramo,stock_gramos,minimo_g,maximo_g,admite_barrita) VALUES({quote(name)},'fibra',{quote('Fuente de fibra de tipo '+name.lower())},'Contribuye al aporte de fibra; depende de tolerancia individual','Por verificar','Proveedor demostrativo','assets/img/fibra.svg',0,'Consultar fabricante',{cost},16000,{mini:.8f},{maxi:.8f},{bar});")
for name,fmt,qty,price,desc in pres:
 seed.append(f"INSERT INTO presentaciones(nombre,formato,porciones,precio_base,descripcion) VALUES({quote(name)},{quote(fmt)},{qty},{price},{quote(desc)});")
# 35 SKUs de catálogo independiente: 6 kits base, 8 sabores, 10 complementos, 7 fibras y 4 packs.
products=[]
for i,(name,desc,origin,cost,_,_,_) in enumerate(base): products.append((f'Kit {name}', f'Kit demostrativo: {desc}. Ingredientes y existencia sujetos a disponibilidad.', 'base',299+i*29, 30+i*2,origin))
for i,(name,cost) in enumerate(sabores): products.append((f'Sabor {name} · pack',f'Complemento de sabor {name.lower()} para recetas de proteína; producto ilustrativo.','sabor',99+i*8,35+i*2,'México'))
for i,(name,desc,cost,mini,maxi,bar) in enumerate(sups): products.append((f'Complemento {name}',f'{desc}. Producto educativo de demostración.','suplemento',149+i*13,25+i*2,'Por verificar'))
for i,(name,cost,mini,maxi,bar) in enumerate(fibras): products.append((f'Fibra {name}',f'Fuente de fibra: {name}. Producto educativo de demostración.','fibra',115+i*11,42+i,'Por verificar'))
for i,(name,fmt,qty,price,desc) in enumerate(pres): products.append((f'Pack {name}',f'{desc}. Presentación ilustrativa para catálogo.','pack',price+110,26+i*3,'México'))
assert len(products)==35
for i,(name,desc,cat,price,stock,origin) in enumerate(products,1):
 seed.append('INSERT INTO productos(nombre,descripcion,foto,precio,cantidad_almacen,fabricante,origen,categoria,activo) VALUES('+','.join(map(quote,[name,desc,f'assets/img/product_{i:02d}.svg']))+f",{price},{stock},'crafted (demo)',{quote(origin)},{quote(cat)},1);")
seed.append('-- Total: 31 ingredientes + 4 presentaciones = 35 opciones. Productos en stock: 35.')
(P/'sql'/'seed.sql').write_text('\n'.join(seed)+'\n',encoding='utf8')
print('Products',len(products),'Ingredients',len(base)+len(sabores)+len(sups)+len(fibras))
