# Suite de pruebas unitarias para el conversor DocBook a Quarto Markdown

import sys
import unittest
import xml.etree.ElementTree as ET
from pathlib import Path

# Agregar directorios para importación
sys.path.insert(0, str(Path(__file__).resolve().parent.parent / 'tools' / 'import'))

from docbook_to_qmd import convert_node, ConverterContext, DB_NS
from handlers.headings import handle_section
from handlers.callouts import handle_callout
from handlers.figures import handle_figure
from handlers.tables import handle_table

class TestDocBookToQMD(unittest.TestCase):
    def setUp(self):
        # Crear un contexto simulado
        self.ctx = ConverterContext(
            source_dir=Path('/tmp/fake-source'),
            output_dir=Path('/tmp/fake-output')
        )

    def _convert(self, xml_string):
        """Helper para parsear y convertir un fragmento XML."""
        # Envolver en un namespace root si no tiene namespace declarado
        if 'xmlns' not in xml_string:
            xml_string = f'<wrapper xmlns="{DB_NS}">{xml_string}</wrapper>'
        
        root = ET.fromstring(xml_string)
        # Si fue envuelto, procesar los nodos hijos
        if root.tag.endswith('wrapper'):
            return "".join(convert_node(child, self.ctx) for child in root)
        return convert_node(root, self.ctx)

    def test_headings_level_generation(self):
        # Prueba que la profundidad de sección genere las cabeceras correctas (#, ##, ###)
        xml = """
        <section xml:id="sec1">
            <title>Sección Principal</title>
            <simpara>Texto seccion 1</simpara>
            <section xml:id="sec2">
                <title>Subsección</title>
                <simpara>Texto seccion 2</simpara>
            </section>
        </section>
        """
        output = self._convert(xml)
        self.assertIn("## Sección Principal", output)
        self.assertIn("### Subsección", output)

    def test_callouts_mapping(self):
        # Prueba la traducción de notas y advertencias
        xml_note = "<note><simpara>Esta es una nota importante.</simpara></note>"
        xml_warning = "<warning><simpara>Cuidado con la velocidad.</simpara></warning>"
        
        note_out = self._convert(xml_note)
        warning_out = self._convert(xml_warning)
        
        self.assertEqual(note_out, "\n::: {.callout-note}\nEsta es una nota importante.\n:::\n")
        self.assertEqual(warning_out, "\n::: {.callout-warning}\nCuidado con la velocidad.\n:::\n")

    def test_figures_and_attributes(self):
        # Prueba traducción de figuras con captions, IDs y anchos
        xml = """
        <figure xml:id="fig-05-01">
            <title>Ángulo de Ataque</title>
            <mediaobject>
                <imageobject>
                    <imagedata fileref="imagenes/cap05-aoa.png" width="75%"/>
                </imageobject>
            </mediaobject>
        </figure>
        """
        output = self._convert(xml)
        self.assertIn("![Ángulo de Ataque](imagenes/cap05-aoa.png){#fig-05-01 width='75%'}", output)
        self.assertIn("cap05-aoa.png", self.ctx.imagenes_detectadas)

    def test_tables_pipe_conversion(self):
        # Prueba traducción de tablas a formato Pipe con caption e ID
        xml = """
        <table xml:id="tbl-polar" pgwide="1">
            <title>Polar del Planeador</title>
            <tgroup cols="2">
                <colspec colname="col1"/>
                <colspec colname="col2"/>
                <thead>
                    <row>
                        <entry>Velocidad (km/h)</entry>
                        <entry>Tasa de Caída (m/s)</entry>
                    </row>
                </thead>
                <tbody>
                    <row>
                        <entry>80</entry>
                        <entry>0.8</entry>
                    </row>
                    <row>
                        <entry>100</entry>
                        <entry>1.2</entry>
                    </row>
                </tbody>
            </tgroup>
        </table>
        """
        output = self._convert(xml)
        
        # Verificar cabecera e hileras
        self.assertIn("| Velocidad (km/h) | Tasa de Caída (m/s) |", output)
        self.assertIn("| 80 | 0.8 |", output)
        self.assertIn("| 100 | 1.2 |", output)
        
        # Verificar pie de tabla con ID normalizado
        self.assertIn(": Polar del Planeador {#tbl-polar}", output)

    def test_inline_elements(self):
        # Prueba elementos en negrita, cursiva y enlaces
        xml = """
        <para>El <emphasis role="strong">planeador</emphasis> vuela en la <emphasis>atmósfera</emphasis> según la <link href="https://ejemplo.com">LPI</link>.</para>
        """
        output = self._convert(xml)
        self.assertIn("El **planeador** vuela en la *atmósfera* según la [LPI](https://ejemplo.com).", output)

    def test_indexterm_suppression(self):
        # Prueba que los indexterms se omitan pero su tail se conserve
        xml = """
        <simpara>La <link linkend="glos-sustentacion">sustentación</link><indexterm>
<primary>Sustentación (lift)</primary>
</indexterm> se genera por una diferencia de presiones.</simpara>
        """
        output = self._convert(xml)
        self.assertIn("sustentación se genera por una diferencia de presiones.", output)
        self.assertNotIn("Sustentación (lift)", output)

    def test_tip_callout(self):
        # Prueba que <tip> se mapee a un callout-tip de Quarto
        xml = "<tip><simpara>Consejo de vuelo importante.</simpara></tip>"
        output = self._convert(xml)
        self.assertIn("::: {.callout-tip}", output)
        self.assertIn("Consejo de vuelo importante.", output)
        self.assertIn(":::", output)

    def test_empty_para_stripped(self):
        # Prueba que los párrafos vacíos o con solo espacios se omitan
        xml = "<simpara> </simpara>"
        output = self._convert(xml)
        self.assertEqual(output.strip(), "")

    def test_blockquote(self):
        # Prueba que blockquote se traduzca con prefijos '>'
        xml = "<blockquote role='text-right'><simpara>Línea 1</simpara><simpara>Línea 2</simpara></blockquote>"
        output = self._convert(xml)
        self.assertIn("> Línea 1", output)
        self.assertIn("> Línea 2", output)

    def test_literallayout(self):
        # Prueba que literallayout preserve el formateado de texto y saltos de línea
        xml = "<literallayout><emphasis role='strong'>Negrita</emphasis>\nTexto plano\nLínea 2</literallayout>"
        output = self._convert(xml)
        self.assertIn("**Negrita**", output)
        self.assertIn("Texto plano", output)
        self.assertIn("Línea 2", output)

if __name__ == '__main__':
    unittest.main()

