<?php
declare(strict_types=1);
require_once __DIR__ . '/lib.php';
if ($_SERVER['REQUEST_METHOD'] !== 'POST') { http_response_code(405); exit('Solo POST'); }
require_csrf();
$action = post_str('action',60);
try {
    switch ($action) {
        case 'register':
            $name=post_str('nombre',120);$email=mb_strtolower(post_str('correo',190));$pass=(string)($_POST['password']??'');$birth=post_str('fecha_nacimiento',10);$address=post_str('direccion_postal',450);
            $date=DateTimeImmutable::createFromFormat('!Y-m-d',$birth);
            if(mb_strlen($name)<3 || !filter_var($email,FILTER_VALIDATE_EMAIL) || strlen($pass)<10 || !$date || $date->format('Y-m-d')!==$birth || $date>new DateTimeImmutable() || $date<new DateTimeImmutable('1900-01-01') || mb_strlen($address)<8) throw new DomainException('Revisa nombre, correo, contraseña, fecha y dirección.');
            if(q('SELECT COUNT(*) FROM usuarios WHERE correo=?',[$email])->fetchColumn()) throw new DomainException('Ese correo ya está registrado.');
            q('INSERT INTO usuarios(nombre,correo,password_hash,fecha_nacimiento,direccion_postal) VALUES(?,?,?,?,?)',[$name,$email,password_hash($pass,PASSWORD_DEFAULT),$birth,$address]);
            $_SESSION['usuario_id']=(int)db()->lastInsertId();session_regenerate_id(true);remember_user($_SESSION['usuario_id']);
            flash('success','¡Cuenta creada! Completa tu cuestionario.');go('cuestionario');
        case 'login':
            $email=mb_strtolower(post_str('correo',190));$pass=(string)($_POST['password']??'');
            $u=q('SELECT id,password_hash FROM usuarios WHERE correo=?',[$email])->fetch();
            if(!$u || !password_verify($pass,$u['password_hash'])) throw new DomainException('Correo o contraseña incorrectos.');
            session_regenerate_id(true);$_SESSION['usuario_id']=(int)$u['id'];
            if(!empty($_POST['recordarme'])) remember_user((int)$u['id']);
            flash('success','Bienvenido de nuevo.');go('perfil');
        case 'logout':
            if(!empty($_COOKIE['crafted_remember'])) { $selector=explode(':',$_COOKIE['crafted_remember'])[0];q('DELETE FROM sesiones_persistentes WHERE selector=?',[$selector]); }
            clear_remember_cookie();$_SESSION=[];session_regenerate_id(true);
            flash('success','Has cerrado la sesión.');go('inicio');
        case 'update_profile':
            $u=require_user();$name=post_str('nombre',120);$address=post_str('direccion_postal',450);
            if(mb_strlen($name)<3 || mb_strlen($address)<8) throw new DomainException('Nombre o dirección demasiado cortos.');
            q('UPDATE usuarios SET nombre=?,direccion_postal=? WHERE id=?',[$name,$address,$u['id']]);flash('success','Tu perfil se actualizó.');go('perfil');
        case 'save_quiz':
            $u=require_user();$weight=(float)($_POST['peso_kg']??0);$height=(float)($_POST['estatura_cm']??0);$days=(int)($_POST['dias_entrenamiento']??-1);$act=post_str('actividad',15);$diet=post_str('alimentacion',15);$exercise=post_str('tipo_ejercicio',90);$allergies=post_str('alergias',255);$organic=!empty($_POST['prefiere_organico'])?1:0;
            $goals=array_values(array_unique(array_filter((array)($_POST['objetivos']??[]),fn($x)=>is_string($x)&&in_array($x,['masa','rendimiento','energia','sueno','digestion','bienestar'],true))));
            if($weight<20||$weight>350||$height<100||$height>250||$days<0||$days>7||!in_array($act,['baja','ligera','moderada','alta'],true)||!in_array($diet,['omnivora','vegetariana','vegana','otra'],true)||empty($_POST['consiente_datos'])) throw new DomainException('Completa los datos válidos y tu consentimiento explícito.');
            db()->beginTransaction();
            q('INSERT INTO perfiles(usuario_id,peso_kg,estatura_cm,actividad,dias_entrenamiento,tipo_ejercicio,alimentacion,alergias,prefiere_organico,consiente_datos) VALUES(?,?,?,?,?,?,?,?,?,1) ON DUPLICATE KEY UPDATE peso_kg=VALUES(peso_kg),estatura_cm=VALUES(estatura_cm),actividad=VALUES(actividad),dias_entrenamiento=VALUES(dias_entrenamiento),tipo_ejercicio=VALUES(tipo_ejercicio),alimentacion=VALUES(alimentacion),alergias=VALUES(alergias),prefiere_organico=VALUES(prefiere_organico),consiente_datos=1',[$u['id'],$weight,$height,$act,$days,$exercise,$diet,$allergies,$organic]);
            q('DELETE FROM objetivos_usuarios WHERE usuario_id=?',[$u['id']]); foreach($goals as $goal) q('INSERT INTO objetivos_usuarios(usuario_id,objetivo) VALUES(?,?)',[$u['id'],$goal]);
            db()->commit();flash('success','Cuestionario guardado.');go('recomendaciones');
        case 'add_cart':
            $u=require_user();$id=(int)($_POST['producto_id']??0);$qty=(int)($_POST['cantidad']??1);
            $p=q('SELECT * FROM productos WHERE id=? AND activo=1',[$id])->fetch();
            if(!$p || $qty<1 || $qty>99) throw new DomainException('Producto o cantidad no válidos.');
            $existing=(int)q('SELECT COALESCE(cantidad,0) FROM carrito WHERE usuario_id=? AND producto_id=?',[$u['id'],$id])->fetchColumn();
            if($existing+$qty>$p['cantidad_almacen'] || $existing+$qty>99) throw new DomainException('No hay suficiente inventario para agregar esa cantidad.');
            q('INSERT INTO carrito(usuario_id,producto_id,cantidad) VALUES(?,?,?) ON DUPLICATE KEY UPDATE cantidad=cantidad+VALUES(cantidad)',[$u['id'],$id,$qty]);
            flash('success','Producto añadido a tu carrito.');go('carrito');
        case 'cart_qty':
            $u=require_user();$id=(int)($_POST['carrito_id']??0);$qty=(int)($_POST['cantidad']??0);
            if($qty<1||$qty>99) throw new DomainException('Cantidad inválida.');
            $item=q('SELECT c.*,p.cantidad_almacen FROM carrito c LEFT JOIN productos p ON c.producto_id=p.id WHERE c.id=? AND c.usuario_id=?',[$id,$u['id']])->fetch();
            if(!$item) throw new DomainException('Artículo no encontrado.');
            if($item['producto_id'] && $qty>$item['cantidad_almacen']) throw new DomainException('No hay suficientes productos disponibles.');
            q('UPDATE carrito SET cantidad=? WHERE id=? AND usuario_id=?',[$qty,$id,$u['id']]);flash('success','Cantidad actualizada.');go('carrito');
        case 'cart_remove':
            $u=require_user();$id=(int)($_POST['carrito_id']??0);
            q('DELETE FROM carrito WHERE id=? AND usuario_id=?',[$id,$u['id']]);flash('success','Producto eliminado.');go('carrito');
        case 'save_formula':
            $u=require_user();$name=post_str('nombre',150);$baseId=(int)($_POST['base_id']??0);$saborId=(int)($_POST['sabor_id']??0);$packId=(int)($_POST['presentacion_id']??0);
            $base=q("SELECT * FROM ingredientes WHERE id=? AND categoria='base' AND activo=1",[$baseId])->fetch();
            $sabor=q("SELECT * FROM ingredientes WHERE id=? AND categoria='sabor' AND activo=1",[$saborId])->fetch();
            $pack=q('SELECT * FROM presentaciones WHERE id=? AND activo=1',[$packId])->fetch();
            if(!$base || !$sabor || !$pack || mb_strlen($name)<2) throw new DomainException('Selecciona una base, un sabor y una presentación válidos.');
            $profile=q('SELECT * FROM perfiles WHERE usuario_id=?',[$u['id']])->fetch();
            if($profile) {
                if($profile['alimentacion']==='vegana' && in_array($base['nombre'],['Proteína de suero (Whey)','Aislado de suero'],true)) throw new DomainException('Tu perfil indica alimentación vegana. Elige una base vegetal.');
                $allergies=mb_strtolower($profile['alergias']);
                if((str_contains($allergies,'leche')||str_contains($allergies,'lácte')) && in_array($base['nombre'],['Proteína de suero (Whey)','Aislado de suero'],true)) throw new DomainException('Tu perfil registra alergia a leche; selecciona una base sin leche.');
                if(str_contains($allergies,'soya') && $base['nombre']==='Proteína de soya') throw new DomainException('Tu perfil registra alergia a soya; selecciona otra base.');
            }
            $extraPost=(array)($_POST['extras']??[]);$extraKeys=array_keys($extraPost);foreach($extraKeys as $k) if(!ctype_digit((string)$k)) throw new DomainException('Ingrediente inválido.');
            $extraList=q("SELECT * FROM ingredientes WHERE categoria IN ('suplemento','fibra') AND activo=1")->fetchAll();
            $lookup=[];foreach($extraList as $ing) $lookup[(int)$ing['id']]=$ing;
            $parts=[$baseId=>[$base,25.0],$saborId=>[$sabor,2.0]];$fibra=0.0;$totalGram=27.0;
            foreach($extraPost as $id=>$val){$id=(int)$id;if(!isset($lookup[$id])) throw new DomainException('No se admite el ingrediente solicitado.');if(!is_scalar($val)||!is_numeric($val))throw new DomainException('Cantidad inválida.');$v=(float)$val;
                if(!is_finite($v)||$v<0||abs($v-round($v,8))>0.000000001) throw new DomainException('Cantidad no válida (máximo 8 decimales).');if($v===0.0) continue;
                $ing=$lookup[$id];$min=(float)$ing['minimo_g'];$max=(float)$ing['maximo_g'];
                if($v+0.0000000001<$min || $v>$max+0.0000000001) throw new DomainException('Cantidad fuera del rango de catálogo para '.$ing['nombre']);
                if($pack['formato']==='barrita' && !$ing['admite_barrita']) throw new DomainException('Un ingrediente no admite formato barrita.');
                $parts[$id]=[$ing,$v];$totalGram+=$v;
                if($ing['categoria']==='fibra')$fibra+=$v;
            }
            if($fibra>8) throw new DomainException('El prototipo limita la fibra añadida a 8 g por porción.');
            if($totalGram>50) throw new DomainException('La mezcla de demostración no puede exceder 50 g por porción.');
            $price=(float)$pack['precio_base'];
            foreach($parts as [$ing,$qty]) $price+=(float)$ing['precio_por_gramo']*$qty*(int)$pack['porciones'];
            $price=round($price*1.65+65,2);
            db()->beginTransaction();
            q('INSERT INTO formulas(usuario_id,nombre,base_id,sabor_id,presentacion_id,peso_porcion_g,precio) VALUES(?,?,?,?,?,?,?)',[$u['id'],$name,$baseId,$saborId,$packId,round($totalGram,3),$price]);
            $formulaId=(int)db()->lastInsertId();
            foreach($parts as $id=>[$ing,$qty]) q('INSERT INTO formula_ingredientes(formula_id,ingrediente_id,cantidad_por_porcion_g,precio_por_gramo_snapshot) VALUES(?,?,?,?)',[$formulaId,$id,$qty,$ing['precio_por_gramo']]);
            q('INSERT INTO carrito(usuario_id,formula_id,cantidad) VALUES(?,?,1)',[$u['id'],$formulaId]);db()->commit();
            flash('success','Tu fórmula de demostración se guardó en el carrito.');go('carrito');
        case 'checkout':
            $u=require_user();$address=post_str('direccion_envio',450);if(mb_strlen($address)<8)throw new DomainException('Agrega una dirección de entrega válida.');
            db()->beginTransaction();
            $items=q('SELECT c.*,p.nombre p_nombre,p.precio p_precio,p.activo p_activo,f.nombre f_nombre,f.precio f_precio,pr.porciones FROM carrito c LEFT JOIN productos p ON c.producto_id=p.id LEFT JOIN formulas f ON c.formula_id=f.id LEFT JOIN presentaciones pr ON pr.id=f.presentacion_id WHERE c.usuario_id=? ORDER BY c.id FOR UPDATE',[$u['id']])->fetchAll();
            if(!$items)throw new DomainException('Tu carrito está vacío.');
            $productNeeds=[];$ingredientNeeds=[];$total=0.0;
            foreach($items as $item){$qty=(int)$item['cantidad'];if($qty<1||$qty>99)throw new DomainException('Cantidad inválida en carrito.');
                if($item['producto_id']){if(!$item['p_nombre']||!$item['p_activo'])throw new DomainException('Uno de los productos dejó de estar disponible.');$productNeeds[(int)$item['producto_id']]=($productNeeds[(int)$item['producto_id']]??0)+$qty;$total+=(float)$item['p_precio']*$qty;}
                else {if(!$item['f_nombre']||!$item['porciones'])throw new DomainException('Fórmula no disponible.');$parts=q('SELECT ingrediente_id,cantidad_por_porcion_g FROM formula_ingredientes WHERE formula_id=?',[$item['formula_id']])->fetchAll();foreach($parts as $part){$id=(int)$part['ingrediente_id'];$ingredientNeeds[$id]=($ingredientNeeds[$id]??0)+(float)$part['cantidad_por_porcion_g']*(int)$item['porciones']*$qty;}$total+=(float)$item['f_precio']*$qty;}
            }
            ksort($productNeeds);ksort($ingredientNeeds);
            foreach($productNeeds as $id=>$needed){$stock=q('SELECT cantidad_almacen FROM productos WHERE id=? FOR UPDATE',[$id])->fetchColumn();if($stock===false||(int)$stock<$needed)throw new DomainException('Stock insuficiente para el producto #'.$id);}
            foreach($ingredientNeeds as $id=>$needed){$stock=q('SELECT stock_gramos FROM ingredientes WHERE id=? AND activo=1 FOR UPDATE',[$id])->fetchColumn();if($stock===false||(float)$stock+1e-7<$needed)throw new DomainException('Faltan ingredientes para producir la fórmula (ID '.$id.').');}
            $total=round($total,2);q("INSERT INTO compras(usuario_id,direccion_envio,total,estado) VALUES(?,?,?,'simulado')",[$u['id'],$address,$total]);$orderId=(int)db()->lastInsertId();
            foreach($items as $item){$name=$item['producto_id']?$item['p_nombre']:$item['f_nombre'];$unit=(float)($item['producto_id']?$item['p_precio']:$item['f_precio']);$qty=(int)$item['cantidad'];q('INSERT INTO detalle_compra(compra_id,producto_id,formula_id,nombre_snapshot,cantidad,precio_unitario,subtotal) VALUES(?,?,?,?,?,?,?)',[$orderId,$item['producto_id'],$item['formula_id'],$name,$qty,$unit,round($qty*$unit,2)]);}
            foreach($productNeeds as $id=>$needed) q('UPDATE productos SET cantidad_almacen=cantidad_almacen-? WHERE id=?',[$needed,$id]);
            foreach($ingredientNeeds as $id=>$needed) q('UPDATE ingredientes SET stock_gramos=stock_gramos-? WHERE id=?',[$needed,$id]);
            q('DELETE FROM carrito WHERE usuario_id=?',[$u['id']]);db()->commit();
            flash('success',"¡Compra simulada #$orderId finalizada! Inventario e historial actualizados.");go('pedidos');
        case 'admin_product':
            require_admin();$id=(int)($_POST['producto_id']??0);$name=post_str('nombre',170);$desc=post_str('descripcion',1500);$price=(float)($_POST['precio']??-1);$stock=(int)($_POST['cantidad_almacen']??-1);$maker=post_str('fabricante',120);$origin=post_str('origen',120);$category=post_str('categoria',30);$active=isset($_POST['activo'])?1:0;
            if(strlen($name)<3||strlen($desc)<10||$price<0||$price>1000000||$stock<0||$stock>1000000||!in_array($category,['base','sabor','suplemento','fibra','pack'],true)||!$maker||!$origin)throw new DomainException('Revisa los campos del producto.');
            $old=$id?q('SELECT * FROM productos WHERE id=?',[$id])->fetch():null;
            if($id&&!$old)throw new DomainException('Producto no encontrado.');
            $photo=$old['foto']??'assets/img/'.$category.'.svg';
            if(isset($_FILES['foto'])&&$_FILES['foto']['error']!==UPLOAD_ERR_NO_FILE){
                if($_FILES['foto']['error']!==UPLOAD_ERR_OK||$_FILES['foto']['size']>2*1024*1024)throw new DomainException('La foto debe medir menos de 2 MB.');
                $mime=(new finfo(FILEINFO_MIME_TYPE))->file($_FILES['foto']['tmp_name']);$ext=['image/jpeg'=>'jpg','image/png'=>'png','image/webp'=>'webp'][$mime]??null;
                if(!$ext||!getimagesize($_FILES['foto']['tmp_name']))throw new DomainException('Solo se admiten imágenes JPG, PNG y WebP.');
                $photo='uploads/'.bin2hex(random_bytes(15)).'.'.$ext;
                if(!move_uploaded_file($_FILES['foto']['tmp_name'],__DIR__.'/'.$photo))throw new DomainException('No se pudo guardar la foto.');
            }
            if($id){q('UPDATE productos SET nombre=?,descripcion=?,foto=?,precio=?,cantidad_almacen=?,fabricante=?,origen=?,categoria=?,activo=? WHERE id=?',[$name,$desc,$photo,$price,$stock,$maker,$origin,$category,$active,$id]);}
            else{q('INSERT INTO productos(nombre,descripcion,foto,precio,cantidad_almacen,fabricante,origen,categoria,activo) VALUES(?,?,?,?,?,?,?,?,?)',[$name,$desc,$photo,$price,$stock,$maker,$origin,$category,$active]);$id=(int)db()->lastInsertId();}
            flash('success','Producto guardado correctamente.');go('admin_producto',['id'=>$id]);
        default: http_response_code(404);exit('Acción no reconocida');
    }
} catch (DomainException $ex) {
    if(db()->inTransaction())db()->rollBack();
    flash('danger',$ex->getMessage());
    $fallback=['register'=>'registro','login'=>'acceso','update_profile'=>'perfil','save_quiz'=>'cuestionario','save_formula'=>'crear','checkout'=>'carrito','admin_product'=>'admin_producto','add_cart'=>'catalogo','cart_qty'=>'carrito','cart_remove'=>'carrito'][$action]??'inicio';
    go($fallback);
} catch (PDOException $ex) {
    if(db()->inTransaction())db()->rollBack();
    error_log($ex->getMessage());
    flash('danger','No se pudo completar la operación. Comprueba los datos o la conexión.');
    go('inicio');
}
