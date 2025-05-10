// 数学公式帮助内容
export const mathHelpContent = `
<div style="max-height: 400px; overflow-y: auto; padding: 10px;">
  <h3 style="margin-top: 0;">常用数学公式输入方法</h3>
  <p>在数学公式编辑框中输入LaTeX格式的公式，使用以下语法：</p>

  <h4>基础运算</h4>
  <table style="width: 100%; border-collapse: collapse;">
    <tr>
      <th style="text-align: left; padding: 5px; border-bottom: 1px solid #ddd;">语法</th>
      <th style="text-align: left; padding: 5px; border-bottom: 1px solid #ddd;">说明</th>
      <th style="text-align: left; padding: 5px; border-bottom: 1px solid #ddd;">效果</th>
      <th style="text-align: center; padding: 5px; border-bottom: 1px solid #ddd;">操作</th>
    </tr>
    <tr>
      <td style="padding: 5px; border-bottom: 1px solid #eee;"><code>a + b</code></td>
      <td style="padding: 5px; border-bottom: 1px solid #eee;">加法</td>
      <td style="padding: 5px; border-bottom: 1px solid #eee;" class="formula-display">$$a + b$$</td>
      <td style="padding: 5px; border-bottom: 1px solid #eee; text-align: center;"><button class="use-formula-btn" data-formula="a + b">使用</button></td>
    </tr>
    <tr>
      <td style="padding: 5px; border-bottom: 1px solid #eee;"><code>a - b</code></td>
      <td style="padding: 5px; border-bottom: 1px solid #eee;">减法</td>
      <td style="padding: 5px; border-bottom: 1px solid #eee;" class="formula-display">$$a - b$$</td>
      <td style="padding: 5px; border-bottom: 1px solid #eee; text-align: center;"><button class="use-formula-btn" data-formula="a - b">使用</button></td>
    </tr>
    <tr>
      <td style="padding: 5px; border-bottom: 1px solid #eee;"><code>a \\times b</code></td>
      <td style="padding: 5px; border-bottom: 1px solid #eee;">乘法</td>
      <td style="padding: 5px; border-bottom: 1px solid #eee;" class="formula-display">$$a \\times b$$</td>
      <td style="padding: 5px; border-bottom: 1px solid #eee; text-align: center;"><button class="use-formula-btn" data-formula="a \\times b">使用</button></td>
    </tr>
    <tr>
      <td style="padding: 5px; border-bottom: 1px solid #eee;"><code>a \\div b</code></td>
      <td style="padding: 5px; border-bottom: 1px solid #eee;">除法</td>
      <td style="padding: 5px; border-bottom: 1px solid #eee;" class="formula-display">$$a \\div b$$</td>
      <td style="padding: 5px; border-bottom: 1px solid #eee; text-align: center;"><button class="use-formula-btn" data-formula="a \\div b">使用</button></td>
    </tr>
    <tr>
      <td style="padding: 5px; border-bottom: 1px solid #eee;"><code>\\frac{a}{b}</code></td>
      <td style="padding: 5px; border-bottom: 1px solid #eee;">分数</td>
      <td style="padding: 5px; border-bottom: 1px solid #eee;" class="formula-display">$$\\frac{a}{b}$$</td>
      <td style="padding: 5px; border-bottom: 1px solid #eee; text-align: center;"><button class="use-formula-btn" data-formula="\\frac{a}{b}">使用</button></td>
    </tr>
    <tr>
      <td style="padding: 5px; border-bottom: 1px solid #eee;"><code>a^b</code></td>
      <td style="padding: 5px; border-bottom: 1px solid #eee;">上标/指数</td>
      <td style="padding: 5px; border-bottom: 1px solid #eee;" class="formula-display">$$a^b$$</td>
      <td style="padding: 5px; border-bottom: 1px solid #eee; text-align: center;"><button class="use-formula-btn" data-formula="a^b">使用</button></td>
    </tr>
    <tr>
      <td style="padding: 5px; border-bottom: 1px solid #eee;"><code>a_b</code></td>
      <td style="padding: 5px; border-bottom: 1px solid #eee;">下标</td>
      <td style="padding: 5px; border-bottom: 1px solid #eee;" class="formula-display">$$a_b$$</td>
      <td style="padding: 5px; border-bottom: 1px solid #eee; text-align: center;"><button class="use-formula-btn" data-formula="a_b">使用</button></td>
    </tr>
    <tr>
      <td style="padding: 5px; border-bottom: 1px solid #eee;"><code>\\sqrt{x}</code></td>
      <td style="padding: 5px; border-bottom: 1px solid #eee;">平方根</td>
      <td style="padding: 5px; border-bottom: 1px solid #eee;" class="formula-display">$$\\sqrt{x}$$</td>
      <td style="padding: 5px; border-bottom: 1px solid #eee; text-align: center;"><button class="use-formula-btn" data-formula="\\sqrt{x}">使用</button></td>
    </tr>
    <tr>
      <td style="padding: 5px; border-bottom: 1px solid #eee;"><code>\\sqrt[n]{x}</code></td>
      <td style="padding: 5px; border-bottom: 1px solid #eee;">n次方根</td>
      <td style="padding: 5px; border-bottom: 1px solid #eee;" class="formula-display">$$\\sqrt[n]{x}$$</td>
      <td style="padding: 5px; border-bottom: 1px solid #eee; text-align: center;"><button class="use-formula-btn" data-formula="\\sqrt[n]{x}">使用</button></td>
    </tr>
  </table>

  <h4 style="margin-top: 15px;">高级符号</h4>
  <table style="width: 100%; border-collapse: collapse;">
    <tr>
      <th style="text-align: left; padding: 5px; border-bottom: 1px solid #ddd;">语法</th>
      <th style="text-align: left; padding: 5px; border-bottom: 1px solid #ddd;">说明</th>
      <th style="text-align: left; padding: 5px; border-bottom: 1px solid #ddd;">效果</th>
      <th style="text-align: center; padding: 5px; border-bottom: 1px solid #ddd;">操作</th>
    </tr>
    <tr>
      <td style="padding: 5px; border-bottom: 1px solid #eee;"><code>\\sum_{i=1}^{n} i</code></td>
      <td style="padding: 5px; border-bottom: 1px solid #eee;">求和</td>
      <td style="padding: 5px; border-bottom: 1px solid #eee;" class="formula-display">$$\\sum_{i=1}^{n} i$$</td>
      <td style="padding: 5px; border-bottom: 1px solid #eee; text-align: center;"><button class="use-formula-btn" data-formula="\\sum_{i=1}^{n} i">使用</button></td>
    </tr>
    <tr>
      <td style="padding: 5px; border-bottom: 1px solid #eee;"><code>\\prod_{i=1}^{n} i</code></td>
      <td style="padding: 5px; border-bottom: 1px solid #eee;">连乘</td>
      <td style="padding: 5px; border-bottom: 1px solid #eee;" class="formula-display">$$\\prod_{i=1}^{n} i$$</td>
      <td style="padding: 5px; border-bottom: 1px solid #eee; text-align: center;"><button class="use-formula-btn" data-formula="\\prod_{i=1}^{n} i">使用</button></td>
    </tr>
    <tr>
      <td style="padding: 5px; border-bottom: 1px solid #eee;"><code>\\int_{a}^{b} f(x) dx</code></td>
      <td style="padding: 5px; border-bottom: 1px solid #eee;">积分</td>
      <td style="padding: 5px; border-bottom: 1px solid #eee;" class="formula-display">$$\\int_{a}^{b} f(x) dx$$</td>
      <td style="padding: 5px; border-bottom: 1px solid #eee; text-align: center;"><button class="use-formula-btn" data-formula="\\int_{a}^{b} f(x) dx">使用</button></td>
    </tr>
    <tr>
      <td style="padding: 5px; border-bottom: 1px solid #eee;"><code>\\lim_{x \\to 0} f(x)</code></td>
      <td style="padding: 5px; border-bottom: 1px solid #eee;">极限</td>
      <td style="padding: 5px; border-bottom: 1px solid #eee;" class="formula-display">$$\\lim_{x \\to 0} f(x)$$</td>
      <td style="padding: 5px; border-bottom: 1px solid #eee; text-align: center;"><button class="use-formula-btn" data-formula="\\lim_{x \\to 0} f(x)">使用</button></td>
    </tr>
    <tr>
      <td style="padding: 5px; border-bottom: 1px solid #eee;"><code>\\frac{d}{dx}f(x)</code></td>
      <td style="padding: 5px; border-bottom: 1px solid #eee;">导数</td>
      <td style="padding: 5px; border-bottom: 1px solid #eee;" class="formula-display">$$\\frac{d}{dx}f(x)$$</td>
      <td style="padding: 5px; border-bottom: 1px solid #eee; text-align: center;"><button class="use-formula-btn" data-formula="\\frac{d}{dx}f(x)">使用</button></td>
    </tr>
    <tr>
      <td style="padding: 5px; border-bottom: 1px solid #eee;"><code>\\infty</code></td>
      <td style="padding: 5px; border-bottom: 1px solid #eee;">无穷符号</td>
      <td style="padding: 5px; border-bottom: 1px solid #eee;" class="formula-display">$$\\infty$$</td>
      <td style="padding: 5px; border-bottom: 1px solid #eee; text-align: center;"><button class="use-formula-btn" data-formula="\\infty">使用</button></td>
    </tr>
    <tr>
      <td style="padding: 5px; border-bottom: 1px solid #eee;"><code>\\pi, \\alpha, \\beta</code></td>
      <td style="padding: 5px; border-bottom: 1px solid #eee;">希腊字母</td>
      <td style="padding: 5px; border-bottom: 1px solid #eee;" class="formula-display">$$\\pi, \\alpha, \\beta$$</td>
      <td style="padding: 5px; border-bottom: 1px solid #eee; text-align: center;"><button class="use-formula-btn" data-formula="\\pi, \\alpha, \\beta">使用</button></td>
    </tr>
  </table>

  <h4 style="margin-top: 15px;">矩阵</h4>
  <table style="width: 100%; border-collapse: collapse;">
    <tr>
      <th style="text-align: left; padding: 5px; border-bottom: 1px solid #ddd;">语法</th>
      <th style="text-align: left; padding: 5px; border-bottom: 1px solid #ddd;">效果</th>
      <th style="text-align: center; padding: 5px; border-bottom: 1px solid #ddd;">操作</th>
    </tr>
    <tr>
      <td style="padding: 5px; vertical-align: top;">
        <pre style="background-color: #f5f5f5; padding: 10px; border-radius: 5px; margin: 0;">\\begin{matrix}
a & b \\\\
c & d
\\end{matrix}</pre>
      </td>
      <td style="padding: 5px;" class="formula-display">
        $$\\begin{matrix} a & b \\\\ c & d \\end{matrix}$$
      </td>
      <td style="padding: 5px; text-align: center; vertical-align: middle;">
        <button class="use-formula-btn" data-formula="\\begin{matrix}\na & b \\\\\nc & d\n\\end{matrix}">使用</button>
      </td>
    </tr>
    <tr>
      <td style="padding: 5px; vertical-align: top;">
        <pre style="background-color: #f5f5f5; padding: 10px; border-radius: 5px; margin: 0;">\\begin{pmatrix}
a & b \\\\
c & d
\\end{pmatrix}</pre>
      </td>
      <td style="padding: 5px;" class="formula-display">
        $$\\begin{pmatrix} a & b \\\\ c & d \\end{pmatrix}$$
      </td>
      <td style="padding: 5px; text-align: center; vertical-align: middle;">
        <button class="use-formula-btn" data-formula="\\begin{pmatrix}\na & b \\\\\nc & d\n\\end{pmatrix}">使用</button>
      </td>
    </tr>
  </table>

  <h4 style="margin-top: 15px;">常用公式示例</h4>
  <table style="width: 100%; border-collapse: collapse;">
    <tr>
      <th style="text-align: left; padding: 5px; border-bottom: 1px solid #ddd;">说明</th>
      <th style="text-align: left; padding: 5px; border-bottom: 1px solid #ddd;">语法</th>
      <th style="text-align: left; padding: 5px; border-bottom: 1px solid #ddd;">效果</th>
      <th style="text-align: center; padding: 5px; border-bottom: 1px solid #ddd;">操作</th>
    </tr>
    <tr>
      <td style="padding: 5px; border-bottom: 1px solid #eee;">二次方程</td>
      <td style="padding: 5px; border-bottom: 1px solid #eee;"><code>ax^2 + bx + c = 0</code></td>
      <td style="padding: 5px; border-bottom: 1px solid #eee;" class="formula-display">$$ax^2 + bx + c = 0$$</td>
      <td style="padding: 5px; border-bottom: 1px solid #eee; text-align: center;"><button class="use-formula-btn" data-formula="ax^2 + bx + c = 0">使用</button></td>
    </tr>
    <tr>
      <td style="padding: 5px; border-bottom: 1px solid #eee;">二次方程解</td>
      <td style="padding: 5px; border-bottom: 1px solid #eee;"><code>x = \\frac{-b \\pm \\sqrt{b^2-4ac}}{2a}</code></td>
      <td style="padding: 5px; border-bottom: 1px solid #eee;" class="formula-display">$$x = \\frac{-b \\pm \\sqrt{b^2-4ac}}{2a}$$</td>
      <td style="padding: 5px; border-bottom: 1px solid #eee; text-align: center;"><button class="use-formula-btn" data-formula="x = \\frac{-b \\pm \\sqrt{b^2-4ac}}{2a}">使用</button></td>
    </tr>
    <tr>
      <td style="padding: 5px; border-bottom: 1px solid #eee;">积分公式</td>
      <td style="padding: 5px; border-bottom: 1px solid #eee;"><code>\\int_{a}^{b} x^2 dx = \\left[ \\frac{x^3}{3} \\right]_{a}^{b}</code></td>
      <td style="padding: 5px; border-bottom: 1px solid #eee;" class="formula-display">$$\\int_{a}^{b} x^2 dx = \\left[ \\frac{x^3}{3} \\right]_{a}^{b}$$</td>
      <td style="padding: 5px; border-bottom: 1px solid #eee; text-align: center;"><button class="use-formula-btn" data-formula="\\int_{a}^{b} x^2 dx = \\left[ \\frac{x^3}{3} \\right]_{a}^{b}">使用</button></td>
    </tr>
    <tr>
      <td style="padding: 5px; border-bottom: 1px solid #eee;">泰勒展开</td>
      <td style="padding: 5px; border-bottom: 1px solid #eee;"><code>f(x) = \\sum_{n=0}^{\\infty} \\frac{f^{(n)}(a)}{n!} (x-a)^n</code></td>
      <td style="padding: 5px; border-bottom: 1px solid #eee;" class="formula-display">$$f(x) = \\sum_{n=0}^{\\infty} \\frac{f^{(n)}(a)}{n!} (x-a)^n$$</td>
      <td style="padding: 5px; border-bottom: 1px solid #eee; text-align: center;"><button class="use-formula-btn" data-formula="f(x) = \\sum_{n=0}^{\\infty} \\frac{f^{(n)}(a)}{n!} (x-a)^n">使用</button></td>
    </tr>
  </table>

  <style>
    .formula-display {
      min-height: 30px;
    }
    .formula-display mjx-container {
      display: inline-block !important;
      margin: 0 !important;
    }
    .use-formula-btn {
      padding: 2px 8px;
      background-color: #1890ff;
      color: white;
      border: none;
      border-radius: 4px;
      cursor: pointer;
      font-size: 12px;
      transition: background-color 0.3s;
    }
    .use-formula-btn:hover {
      background-color: #40a9ff;
    }
  </style>

  <p style="margin-top: 15px;"><strong>提示：</strong> 点击"使用"按钮可直接在公式编辑器中插入对应的语法。</p>
</div>
`;
