t = Swim.terminals[0]

t.font = Swim.getFont(name: "Glass TTY VT220", size: 20)

t.write(Swim.HTML2ANSI.decode("""
  <span style=\"color: #496d90; background-color: #c0c0c0;\">Some text</span>
  <div>
    <span>More text</span>
  </div>

  <h2>Pretty printed table</h2>
  <table id="invoice">
    <thead>
      <tr>
        <th>Article</th>
        <th>Price</th>
        <th>Taxes</th>
        <th>Amount</th>
        <th>Total</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>
          <p>
            Product 1<br />
            <span style="font-size:0.8em">Contains: 1x Product 1</span>
          </p>
        </td>
        <td align="right" valign="top">6,99&euro;</td>
        <td align="right" valign="top">7%</td>
        <td align="right" valign="top">1</td>
        <td align="right" valign="top">6,99€</td>
      </tr>
      <tr>
        <td>Shipment costs</td>
        <td align="right">3,25€</td>
        <td align="right">7%</td>
        <td align="right">1</td>
        <td align="right">3,25€</td>
      </tr>
    </tbody>
    <tfoot>
      <tr>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
        <td colspan="3">to pay: 10,24€</td>
      </tr>
      <tr>
        <td></td>
        <td></td>
        <td colspan="3">Taxes 7%: 0,72€</td>
      </tr>
    </tfoot>
  </table>
""")).cr.cr
