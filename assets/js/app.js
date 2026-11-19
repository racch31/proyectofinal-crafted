'use strict';
document.addEventListener('DOMContentLoaded',()=>{
  const formula=document.getElementById('formula-builder');
  // 0.30000000000000004 -> "0.3": quita decimales sobrantes de las operaciones con punto flotante.
  const limpio=n=>String(+(+n).toFixed(4));
  if(formula){
    const update=()=>{
      const current=formula.querySelector('input[name=base_id]:checked');
      const selected=formula.querySelector('input[name=sabor_id]:checked');
      const pack=formula.querySelector('input[name=presentacion_id]:checked');
      if(!current||!selected||!pack) return;
      const portions=+pack.dataset.porciones;
      let cost=+pack.dataset.precio, totalG=0;
      const names=[];
      [[current,25],[selected,2]].forEach(([input,qty])=>{cost+= +input.dataset.costo*qty*portions;totalG+=qty;});
      formula.querySelectorAll('.extra-qty').forEach(el=>{
        // Cada campo se captura en su unidad (g, mg o µg); data-factor la convierte a gramos.
        const qty=+(el.value||0), grams=qty*(+el.dataset.factor||1), min=+el.dataset.min||0;
        if(qty>0){cost+=+el.dataset.costo*grams*portions;totalG+=grams;names.push(el.dataset.nombre+' '+limpio(qty)+' '+el.dataset.unidad);}
        const message=el.closest('.extra-row')?.querySelector('.qty-info');
        if(message){message.textContent=qty>+el.max?'Supera el máximo permitido': qty>0&&qty<min?'Menor al mínimo permitido': qty>0?'Añadido':'Opcional';}
      });
      const price=(cost*1.65+65).toLocaleString('es-MX',{style:'currency',currency:'MXN'});
      document.querySelector('#preview-price').textContent=price;
      document.querySelector('#preview-base').textContent=current.dataset.nombre;
      document.querySelector('#preview-sabor').textContent=selected.dataset.nombre;
      document.querySelector('#preview-pack').textContent=pack.dataset.nombre;
      document.querySelector('#preview-extras').textContent=names.join(', ')||'Ninguno';
      document.querySelector('#preview-grams').textContent=totalG.toFixed(1)+' g por porción';
    };
    // Al usar las flechas o salir del campo, la cantidad se ajusta al rango del ingrediente:
    // de 0 sube directo al mínimo, por debajo del mínimo regresa a 0 y nunca pasa del máximo.
    formula.querySelectorAll('.extra-qty').forEach(el=>{
      el.dataset.previo=el.value||'0';
      el.addEventListener('change',()=>{
        const min=+el.dataset.min||0, max=+el.max, previo=+el.dataset.previo||0;
        let v=+(el.value||0);
        if(!isFinite(v)||v<=0) v=0;
        else if(v<min) v=v>previo?min:0;
        else if(v>max) v=max;
        el.value=limpio(v);el.dataset.previo=el.value;
      });
    });
    formula.addEventListener('input',update);formula.addEventListener('change',update);update();
  }
  document.querySelectorAll('[data-confirm]').forEach(el=>el.addEventListener('click',ev=>{if(!confirm(el.dataset.confirm)) ev.preventDefault();}));
});
