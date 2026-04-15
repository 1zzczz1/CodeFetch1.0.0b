const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// 准备Python环境用于打包
function preparePythonForPackaging() {
  const resourcesDir = path.join(__dirname, '..', 'python-runtime');
  
  // 创建python-runtime目录
  if (!fs.existsSync(resourcesDir)) {
    fs.mkdirSync(resourcesDir, { recursive: true });
  }

  console.log('准备Python运行时环境...');
  
  // 检查虚拟环境
  const venvPath = path.join(__dirname, '..', '.venv');
  const venvPython = path.join(venvPath, 'Scripts', 'python.exe');
  
  if (fs.existsSync(venvPython)) {
    console.log('找到虚拟环境，复制依赖...');
    
    // 复制虚拟环境的site-packages
    const sitePackagesSource = path.join(venvPath, 'Lib', 'site-packages');
    const sitePackagesTarget = path.join(resourcesDir, 'Lib', 'site-packages');
    
    if (!fs.existsSync(sitePackagesTarget)) {
      fs.mkdirSync(sitePackagesTarget, { recursive: true });
    }
    
    // 复制关键依赖包
    const requiredPackages = [
      'flask',
      'flask_cors',
      'flask-3.1.3.dist-info',
      'flask_cors-6.0.2.dist-info',
      'pymysql',
      'pymysql-1.1.2.dist-info',
      'cryptography',
      'cryptography-46.0.5.dist-info',
      'jwt',
      'pyjwt-2.12.1.dist-info',
      'werkzeug',
      'werkzeug-3.1.6.dist-info',
      'jinja2',
      'jinja2-3.1.6.dist-info',
      'markupsafe',
      'markupsafe-3.0.3.dist-info',
      'itsdangerous',
      'itsdangerous-2.2.0.dist-info',
      'click',
      'click-8.3.1.dist-info',
      'blinker',
      'blinker-1.9.0.dist-info',
      'colorama',
      'colorama-0.4.6.dist-info',
      'cffi',
      'cffi-2.0.0.dist-info',
      'pycparser',
      'pycparser-3.0.dist-info',
      '_cffi_backend.cp314-win_amd64.pyd'
    ];
    
    for (const pkg of requiredPackages) {
      const sourcePath = path.join(sitePackagesSource, pkg);
      const targetPath = path.join(sitePackagesTarget, pkg);
      
      if (fs.existsSync(sourcePath)) {
        copyRecursive(sourcePath, targetPath);
        console.log(`已复制: ${pkg}`);
      } else {
        console.log(`警告: 未找到 ${pkg}`);
      }
    }
    
    // 复制Python标准库（关键模块）
    const pythonStdLib = path.join(venvPath, 'Lib');
    const targetStdLib = path.join(resourcesDir, 'Lib');
    
    // 复制必要的标准库文件
    const stdLibFiles = [
      'abc.py', 'ast.py', 'base64.py', 'bisect.py', 'bz2.py',
      'calendar.py', 'cgi.py', 'chunk.py', 'cmd.py', 'code.py',
      'codecs.py', 'codeop.py', 'collections', 'colorsys.py',
      'compileall.py', 'concurrent', 'configparser.py', 'contextlib.py',
      'contextvars.py', 'copy.py', 'copyreg.py', 'csv.py',
      'ctypes', 'curses', 'dataclasses.py', 'datetime.py',
      'decimal.py', 'difflib.py', 'dis.py', 'distutils',
      'doctest.py', 'email', 'encodings', 'enum.py', 'filecmp.py',
      'fileinput.py', 'fnmatch.py', 'fractions.py', 'ftplib.py',
      'functools.py', 'genericpath.py', 'getopt.py', 'getpass.py',
      'gettext.py', 'glob.py', 'graphlib.py', 'gzip.py', 'hashlib.py',
      'heapq.py', 'hmac.py', 'html', 'http', 'idlelib', 'imaplib.py',
      'imghdr.py', 'imp.py', 'importlib', 'inspect.py', 'io.py',
      'ipaddress.py', 'json', 'keyword.py', 'lib2to3', 'linecache.py',
      'locale.py', 'logging', 'lzma.py', 'mailbox.py', 'mailcap.py',
      'mimetypes.py', 'modulefinder.py', 'multiprocessing', 'netrc.py',
      'nntplib.py', 'ntpath.py', 'nturl2path.py', 'numbers.py',
      'opcode.py', 'operator.py', 'optparse.py', 'os.py', 'pathlib.py',
      'pdb.py', 'pickle.py', 'pickletools.py', 'pipes.py', 'pkgutil.py',
      'platform.py', 'plistlib.py', 'poplib.py', 'posixpath.py',
      'pprint.py', 'profile.py', 'pstats.py', 'pty.py', 'py_compile.py',
      'pyclbr.py', 'pydoc.py', 'pydoc_data', 'queue.py', 'quopri.py',
      'random.py', 're', 'reprlib.py', 'rlcompleter.py', 'runpy.py',
      'sched.py', 'secrets.py', 'selectors.py', 'shelve.py',
      'shlex.py', 'shutil.py', 'signal.py', 'site-packages',
      'site.py', 'smtpd.py', 'smtplib.py', 'sndhdr.py', 'socket.py',
      'socketserver.py', 'sqlite3', 'ssl.py', 'stat.py', 'statistics.py',
      'string.py', 'stringprep.py', 'struct.py', 'subprocess.py',
      'sunau.py', 'symtable.py', 'sysconfig.py', 'tabnanny.py',
      'tarfile.py', 'telnetlib.py', 'tempfile.py', 'textwrap.py',
      'this.py', 'threading.py', 'timeit.py', 'token.py', 'tokenize.py',
      'trace.py', 'traceback.py', 'tracemalloc.py', 'tty.py',
      'turtle.py', 'turtledemo', 'types.py', 'typing.py', 'unittest',
      'urllib', 'uu.py', 'uuid.py', 'venv', 'warnings.py', 'wave.py',
      'weakref.py', 'webbrowser.py', 'wsgiref', 'xdrlib.py', 'xml',
      'xmlrpc', 'zipapp.py', 'zipfile.py', 'zipimport.py', '_collections_abc.py',
      '_compat_pickle.py', '_compression.py', '_markupbase.py',
      '_osx_support.py', '_pydecimal.py', '_pyio.py', '_sitebuiltins.py',
      '_strptime.py', '_threading_local.py', '_weakrefset.py',
      '__future__.py', '__phello__.foo.py', '_bootsubprocess.py',
      '_aix_support.py'
    ];
    
    for (const file of stdLibFiles) {
      const sourcePath = path.join(pythonStdLib, file);
      const targetPath = path.join(targetStdLib, file);
      
      if (fs.existsSync(sourcePath)) {
        copyRecursive(sourcePath, targetPath);
      }
    }
    
    // 复制python.exe和python3.dll等核心文件
    const venvScripts = path.join(venvPath, 'Scripts');
    const targetScripts = path.join(resourcesDir, 'Scripts');
    
    if (!fs.existsSync(targetScripts)) {
      fs.mkdirSync(targetScripts, { recursive: true });
    }
    
    // 首先尝试从虚拟环境Scripts复制
    const coreFiles = [
      'python.exe',
      'pythonw.exe',
      'python3.dll',
      'python314.dll',
      'vcruntime140.dll',
      'vcruntime140_1.dll'
    ];
    
    // 获取Python基础安装目录
    let pythonInstallDir = '';
    try {
      const pythonExe = path.join(venvScripts, 'python.exe');
      // 获取base_prefix（基础Python安装目录）
      const output = execSync(`"${pythonExe}" -c "import sys; print(sys.base_prefix if hasattr(sys, 'base_prefix') else sys.real_prefix if hasattr(sys, 'real_prefix') else sys.prefix)"`, { encoding: 'utf8' });
      pythonInstallDir = output.trim();
      console.log('Python基础安装目录:', pythonInstallDir);
    } catch (e) {
      console.log('无法获取Python安装目录:', e.message);
    }
    
    for (const file of coreFiles) {
      let sourcePath = path.join(venvScripts, file);
      const targetPath = path.join(targetScripts, file);
      
      // 如果在虚拟环境找不到，尝试从Python安装目录复制
      if (!fs.existsSync(sourcePath) && pythonInstallDir) {
        sourcePath = path.join(pythonInstallDir, file);
      }
      
      if (fs.existsSync(sourcePath)) {
        fs.copyFileSync(sourcePath, targetPath);
        console.log(`已复制: ${file}`);
      } else {
        console.log(`警告: 未找到 ${file}`);
      }
    }
    
    // 复制DLLs目录（包含Python核心DLL）
    if (pythonInstallDir) {
      const dllsSource = path.join(pythonInstallDir, 'DLLs');
      const dllsTarget = path.join(resourcesDir, 'DLLs');
      
      if (fs.existsSync(dllsSource)) {
        copyRecursive(dllsSource, dllsTarget);
        console.log('已复制DLLs目录');
      }
    }
    
    // 创建python310._pth文件来配置Python路径
    const pthContent = `python314.zip
.
Lib
Lib\\site-packages

# Uncomment to run site.main() automatically
import site
`;
    
    fs.writeFileSync(path.join(resourcesDir, 'python314._pth'), pthContent);
    
    console.log('Python运行时环境准备完成！');
    console.log(`位置: ${resourcesDir}`);
    
  } else {
    console.error('错误: 未找到虚拟环境，请先创建虚拟环境并安装依赖');
    console.log('运行: python -m venv .venv && .venv\\Scripts\\pip install -r requirements.txt');
    process.exit(1);
  }
}

// 递归复制文件/目录
function copyRecursive(source, target) {
  const stat = fs.statSync(source);
  
  if (stat.isDirectory()) {
    if (!fs.existsSync(target)) {
      fs.mkdirSync(target, { recursive: true });
    }
    
    const files = fs.readdirSync(source);
    for (const file of files) {
      const sourcePath = path.join(source, file);
      const targetPath = path.join(target, file);
      copyRecursive(sourcePath, targetPath);
    }
  } else {
    fs.copyFileSync(source, target);
  }
}

// 运行准备
preparePythonForPackaging();
