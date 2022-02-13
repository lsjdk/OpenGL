//
//  GLSLManager.swift
//  LSJOpenGLES
//
//  Created by 李世举 on 2022/2/12.
//

import Foundation
import OpenGLES

class GLSLManager {
    
    static func loadProgram(vertexPath: String, fragmentPath: String) -> GLuint {
        
        let vertexShader = self.compile(type: GLenum(GL_VERTEX_SHADER), file: vertexPath)
        if vertexShader == 0 {
            return 0
        }
        let fragmentShder = self.compile(type: GLenum(GL_FRAGMENT_SHADER), file: fragmentPath)
        if fragmentShder == 0 {
            return 0
        }
        
        let programe = glCreateProgram()
        
        if programe == 0 {
            return 0
        }
        
        glAttachShader(programe, vertexShader)
        glAttachShader(programe, fragmentShder)
        
        //链接
        glLinkProgram(programe)
        
        
        var linkStatus: GLint = 0
        
        glGetProgramiv(programe, GLenum(GL_LINK_STATUS), &linkStatus)
        
        if linkStatus == GL_FALSE {
            let bufferLength : GLsizei = 1024
            let info : [GLchar] = Array(repeating: GLchar(0), count: Int(bufferLength))
            var actualLength : GLsizei = 0
            
            glGetProgramInfoLog(programe, bufferLength, &actualLength, UnsafeMutablePointer(mutating: info))
            NSLog(String(validatingUTF8: info)!)
            glDeleteProgram(programe)
            return 0
        }
        glDeleteShader(vertexShader)
        glDeleteShader(fragmentShder)
        return programe
        
    }
    
    //MARK: 加载shader
    static func loadShaers(vertexPath: String, fragmentPath: String) -> GLuint {
        let vertexShader = self.compile(type: GLenum(GL_VERTEX_SHADER), file: vertexPath)
        let fragmentShder = self.compile(type: GLenum(GL_FRAGMENT_SHADER), file: fragmentPath)
        
        let programe = glCreateProgram()
        
        glAttachShader(programe, vertexShader)
        glAttachShader(programe, fragmentShder)
        
        glDeleteShader(vertexShader)
        glDeleteShader(fragmentShder)
        
        return programe
    }
    
    static func compile(type: GLenum, file: String) -> GLuint {
        //创建一个shader（根据type类型）
        let shader = glCreateShader(type)
        //读取文件路径字符串
        let shaderString = try? try NSString(contentsOfFile: file, encoding: String.Encoding.utf8.rawValue)
        
        let shaderStringUTF8 = shaderString!.cString(using: String.defaultCStringEncoding.rawValue)

        //UnsafePointer<UnsafePointer<GLchar>?>
        var glsource = UnsafePointer(shaderStringUTF8)
        
        
        var shaderStringLength: GLint = GLint((shaderString?.length)!)
        
//        let path = try? String.init(contentsOfFile: file)
        
        //UnsafePointer<CChar>?
        
//        let pathU: [CChar] = path?.utf8CString //ContiguousArray<CChar>
        
//        var source = UnsafePointer(pathU)
        
        
        //将顶点着色器源码附加到着色器对象上。
        //参数1：shader,要编译的着色器对象 *shader
        //参数2：numOfStrings,传递的源码字符串数量 1个
        //参数3：strings,着色器程序的源码（真正的着色器程序源码）
        //参数4：lenOfStrings,长度，具有每个字符串长度的数组，或NULL，这意味着字符串是NULL终止的
        glShaderSource(shader, 1, &glsource, &shaderStringLength)
        //把着色器源代码编译成目标代码
        glCompileShader(shader)
        
        return shader
    }
}
