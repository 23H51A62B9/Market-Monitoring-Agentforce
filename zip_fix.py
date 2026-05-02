import zipfile
import os

def create_zip():
    with zipfile.ZipFile('finalDeployFix.zip', 'w', zipfile.ZIP_DEFLATED) as zipf:
        zipf.write('deployPkg/package.xml', 'package.xml')
        for root, dirs, files in os.walk('deployPkg/lwc'):
            for file in files:
                abs_path = os.path.join(root, file)
                rel_path = os.path.relpath(abs_path, 'deployPkg')
                zip_path = rel_path.replace('\\', '/')
                zipf.write(abs_path, zip_path)

if __name__ == '__main__':
    create_zip()
