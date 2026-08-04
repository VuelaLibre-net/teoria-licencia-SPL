// Ejercicio resuelto: enunciado con cifras, procedimiento y resultado.
//
// Navegación y Planificación son las dos asignaturas «de calculadora» del
// temario, y una auditoría externa señaló que el libro 9 las explicaba casi
// todo con palabras. El ejercicio resuelto es el bloque que faltaba: se lee
// como una unidad, se salta de una pasada y se vuelve a él para practicar.
//
// NO es una quinta admonition. Las cuatro categorías del temario —Seguridad,
// Normativa, Regla de oro, Airmanship— son una taxonomía cerrada y esto no
// entra en ella: es un envoltorio más, como `postit` o `mas-alla`, y por eso
// tiene su propia forma y su propio color.
//
// Filete izquierdo en el azul de estructura de la colección (#003366, el mismo
// que GUIA_ILUSTRACIONES.md fija para los ejes y la estructura de las figuras)
// sobre un fondo apenas teñido de azul. Ni amarillo (postit) ni gris
// (mas-alla) ni ninguno de los cuatro colores de las admonitions: al hojear,
// el ejercicio se reconoce sin leerlo.
//
// El cuerpo se queda en la serifa del libro, al contrario que el post-it. Un
// ejercicio es texto para leer despacio, con fórmulas dentro; el post-it es una
// tarjeta de repaso, y ahí el palo seco marca el cambio de registro.

// `breakable: true` es obligatorio: un ejercicio con enunciado, procedimiento y
// solución puede pasar de página, y un bloque no partible lo empujaría entero
// dejando un hueco enorme.
#let ejercicio(body) = block(
  breakable: true,
  width: 100%,
  fill: rgb("#F2F6FA"),
  stroke: (left: 2.5pt + rgb("#003366")),
  inset: (x: 0.6cm, y: 0.5cm),
  above: 1.2em,
  below: 1.2em,
  {
    // set text en vez de text(): la variante función envuelve el contenido en
    // un elemento de texto que interfiere con el motor matemático de Typst y
    // deja las fórmulas fuera de su fuente matemática. Aquí importa más que en
    // ningún otro envoltorio: estos bloques son casi todo matemáticas.
    set par(first-line-indent: 0em)
    body
  },
)
