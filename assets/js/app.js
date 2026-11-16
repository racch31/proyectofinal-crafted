'use strict';
document.addEventListener('DOMContentLoaded',()=>{
  const formula=document.getElementById('formula-builder');
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
        const qty=+(el.value||0); if(qty>0){cost+=+el.dataset.costo*qty*portions;totalG+=qty;names.push(el.dataset.nombre+' '+qty+' g');}
        const message=el.closest('.extra-row')?.querySelector('.qty-info');
        if(message){message.textContent=qty>+el.max?'Supera el límite de catálogo': qty>0?'Añadido':'Opcional';}
      });
      const price=(cost*1.65+65).toLocaleString('es-MX',{style:'currency',currency:'MXN'});
      document.querySelector('#preview-price').textContent=price;
      document.querySelector('#preview-base').textContent=current.dataset.nombre;
      document.querySelector('#preview-sabor').textContent=selected.dataset.nombre;
      document.querySelector('#preview-pack').textContent=pack.dataset.nombre;
      document.querySelector('#preview-extras').textContent=names.join(', ')||'Ninguno';
      document.querySelector('#preview-grams').textContent=totalG.toFixed(1)+' g por porción';
    };
    formula.addEventListener('input',update);formula.addEventListener('change',update);update();
  }
  document.querySelectorAll('[data-confirm]').forEach(el=>el.addEventListener('click',ev=>{if(!confirm(el.dataset.confirm)) ev.preventDefault();}));
});
