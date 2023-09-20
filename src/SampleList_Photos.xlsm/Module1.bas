Attribute VB_Name = "Module1"
Option Explicit
Sub createMasterData()
    '**********************************
    '   Master�f�[�^�쐬����
    '
    '   Created by: Takashi Kawamoto
    '   Created on: 2023/9/6
    '**********************************
    
    Dim masterDir
    Dim strEqNo
    Dim eqNoClm
    Dim toClm
    Dim arrEqNo As Variant
    Dim posNum
    Dim i, j, k
    Dim strPre, strNum
    Dim arrNum As Variant
    Dim strFromEqNo
    Dim fromNum, toNum
    Dim wtRow
    Dim wb As Workbook
    Dim oldFileName, newFileName
    Dim oldFilePath, newFilePath

    'temp�t�H���_�L���`�F�b�N
    If Dir("c:\temp", vbDirectory) = "" Then
        MkDir "c:\temp"
    End If
    
    'Master�f�[�^�t�H���_
    masterDir = ThisWorkbook.Path & "\Master"
    
    'Master�f�[�^�t�H���_���Ȃ��ꍇ�͐V�K�쐬���違Master(Excel)���̋Ɩ��ԍ����N���A����
    If Dir(masterDir, vbDirectory) = "" Then
        MkDir masterDir
        ThisWorkbook.Sheets("SampleList").Cells(1, 1).Clear
        
    'Master�f�[�^�t�H���_�����ɑ��݂���ꍇ�́A�m�F���b�Z�[�W���o���ď����𒆎~����B(����ď���������̂�h������)
    Else
        MsgBox ("Master�t�H���_�����݂��܂��B" & Chr(10) & "�������������ꍇ�ͤMaster�t�H���_���폜���Ă���Ď��s���Ă��������")
        Exit Sub
    End If
    
    '�@��No����
    strEqNo = InputBox("�@��No�H(��FS01-10,E01-99,H01-99)", , "S01-10,E01-99,H01-99")
    
    '���p/�S�p�X�y�[�X���폜
    strEqNo = Replace(strEqNo, " ", "")
    strEqNo = Replace(strEqNo, "�@", "")
    
    '�����͂Ȃ珈�����~
    If strEqNo = "" Then
        MsgBox ("�����𒆎~���܂��B(�@��No������)")
        GoTo abort
    End If
    
    '�@��No���uSampleList�v�V�[�g�ɏ����o��
    eqNoClm = 6
    toClm = 13
    wtRow = 2
    With ThisWorkbook.Sheets("SampleList")
    
        '�����o���G���A�N���A
        .Range(.Cells(2, eqNoClm), .Cells(1048576, eqNoClm)).ClearContents
    
        arrEqNo = Split(strEqNo, ",")
        For i = 0 To UBound(arrEqNo)
            
            '���͒l�Ɂu-�v���Ȃ��ꍇ�͏����𒆎~����
            If InStr(arrEqNo(i), "-") = 0 Then
                MsgBox ("�����𒆎~���܂��B" & Chr(10) & "�@��No�̊J�n�ԍ��ƏI���ԍ��̊ԂɁu-�v��ǉ����Ă��������B" & Chr(10) & "���͒l�F" & arrEqNo(i))
                GoTo abort
            End If

            '���͒l(�J�n�ԍ�)�������猩�čŏ��Ɂu0�v�����������ʒu�̎�O�܂ł��@��No�̐ړ���(�uE�v��)�Ɣ��ʂ���
            strFromEqNo = Left(arrEqNo(i), InStr(arrEqNo(i), "-") - 1)
            posNum = InStr(strFromEqNo, "0")
            
            '���͒l�Ɂu0�v��������Ȃ��ꍇ�A�������~
            If posNum = 0 Then
                MsgBox ("�����𒆎~���܂��B" & Chr(10) & "�@��No�̊J�n�ԍ��͂O���߂Ŏw�肵�Ă��������B(��FE01, E001, H01, ��)" & Chr(10) & "���͒l�F" & arrEqNo(i))
                GoTo abort
            End If
            
            '�@��No�̐ړ�����擾����
            strPre = Left(arrEqNo(i), posNum - 1)   '�@��No�̐ړ���
            
            '�ړ���`�F�b�N
            If strPre = "" Then
                MsgBox ("�����𒆎~���܂��B(�@��No�̐ړ��ꂪ���ʂł��܂���)" & Chr(10) & "���͒l�F" & arrEqNo(i))
                GoTo abort
            End If
            For k = 1 To Len(strPre)
                If IsNumeric(Mid(strPre, k, 1)) Then
                    MsgBox ("�����𒆎~���܂��B(�@��No�̐ړ���ɐ����͓�����܂���)" & Chr(10) & "�ړ���F" & strPre & Chr(10) & "���͒l�F" & arrEqNo(i))
                    GoTo abort
                End If
            Next k
            
            '�@��No�̊J�n�ԍ��ƏI���ԍ����擾����
            strNum = Mid(arrEqNo(i), posNum)
            arrNum = Split(strNum, "-")
            fromNum = arrNum(0) '�@��No-�J�n�ԍ�
            toNum = arrNum(1)   '�@��No-�I���ԍ�
            toNum = Replace(toNum, strPre, "")  '�@��No�̏I���ԍ��ɐړ��ꂪ�܂܂��ꍇ�͐ړ�����폜���Đ��l������
            
            '�J�n�ԍ�-�I���ԍ��`�F�b�N
            If IsNumeric(fromNum) = False Or IsNumeric(toNum) = False Then
                MsgBox ("�����𒆎~���܂��B(�@��No�̊J�n�E�I���ԍ������l�ł͂���܂���)" & Chr(10) & "�ړ���F" & strPre & Chr(10) & "�J�n�ԍ��F" & fromNum & Chr(10) & "�I���ԍ��F" & toNum)
                GoTo abort
            End If
            If CInt(fromNum) > CInt(toNum) Then
                MsgBox ("�����𒆎~���܂��B(�@��No�̊J�n�ԍ����I���ԍ����傫���Ȃ��Ă��܂�)" & Chr(10) & "�ړ���F" & strPre & Chr(10) & "�J�n�ԍ��F" & fromNum & Chr(10) & "�I���ԍ��F" & toNum)
                GoTo abort
            End If
            '�f�o�b�O�p
            'MsgBox ("fromNum: " & fromNum & " toNum: " & toNum)
            
            '�@��No�̊J�n�ԍ�����I���ԍ��܂ŏ������J��Ԃ�
            For j = CInt(fromNum) To CInt(toNum)
            
                '���l�����`�F�b�N
                If Len(toNum) >= 4 Then
                    MsgBox ("�������I�����܂��B(�@��No�̐��l�͍ő�3���܂�)" & Chr(10) & "���͒l�F" & toNum)
                    GoTo abort
                End If
                
                '�I���ԍ��̌����ɂ��ԍ��̃[�����߂�����
                Select Case Len(toNum)
                Case 1
                    .Cells(wtRow, eqNoClm) = strPre & Format(j, "0")
                Case 2
                    .Cells(wtRow, eqNoClm) = strPre & Format(j, "00")
                Case 3
                    .Cells(wtRow, eqNoClm) = strPre & Format(j, "000")
                End Select
                
                '�Z�������ݒ�
                With .Range(.Cells(wtRow, eqNoClm), .Cells(wtRow, toClm))
                    .VerticalAlignment = xlCenter
                End With
                
                '�����o���s�ԍ��C���N�������g
                wtRow = wtRow + 1
            Next j
        Next i
    End With
    
    'PLIST�V�K�쐬����
    Call createPlist(eqNoClm)
    
    'ZIP�t�@�C���V�K�쐬����
    Call createZip
    
    'Master(Excel)�ۑ�
    Set wb = ThisWorkbook
    If wb.ReadOnly = True Then
        oldFileName = ThisWorkbook.Name
        oldFilePath = ThisWorkbook.Path & "\" & ThisWorkbook.Name
        newFileName = "@" & ThisWorkbook.Name
        newFilePath = ThisWorkbook.Path & "\@" & ThisWorkbook.Name
        ThisWorkbook.SaveAs newFilePath
        If Dir(oldFilePath) <> "" Then
            If Dir(ThisWorkbook.Path & "\old", vbDirectory) = "" Then
                MkDir ThisWorkbook.Path & "\old"
            End If
            Name oldFilePath As ThisWorkbook.Path & "\old\�y���z" & oldFileName
        End If
        MsgBox ("Master(Excel)�t�@�C�����ǂݎ���p�̂��ߕʖ��ŕۑ����܂���" & Chr(10) & newFileName)
    Else
        ThisWorkbook.Save
    End If
    
    '�I������
    MsgBox ("Master�f�[�^�쐬����")
    Exit Sub
    
abort:
        'Master�f�[�^�t�H���_�폜
        If Dir(masterDir, vbDirectory) <> "" Then
            With CreateObject("Scripting.FileSystemObject")
                .DeleteFolder masterDir
            End With
        End If
    
End Sub
Sub createPlist(eqNoClm)
    '**********************************
    '   PLIST�V�K�쐬����
    '
    '   Created by: Takashi Kawamoto
    '   Created on: 2023/9/6
    '**********************************
    
    Dim xmlDoc      As MSXML2.DOMDocument60
    Dim xmlPI       As IXMLDOMProcessingInstruction
    Dim node(8)     As IXMLDOMNode
    Dim str         As String
    Dim fileName    As String
    Dim fileData    As Variant
    Dim find()      As Variant
    Dim rep()       As Variant
    Dim i        As Integer
    Dim tempFile
    Dim startRow, maxRow
    
    With ThisWorkbook.Sheets("SampleList")
    
        tempFile = "c:\\temp\\temp.plist"   '�ꎞ�t�@�C��
        fileName = ThisWorkbook.Path & "\Master\SampleList&img.plist" 'new plist(=Master�f�[�^)��Master(Excel)�̓���K�w�́uMaster�v�t�H���_�ɏo�͂����
                
        'XML�t�@�C���o�͏���
        Set xmlDoc = New MSXML2.DOMDocument60
        Set xmlPI = xmlDoc.appendChild(xmlDoc.createProcessingInstruction("xml", "version=""1.0"" encoding=""UTF-8"""))
        Set xmlPI = xmlDoc.appendChild(xmlDoc.createProcessingInstruction("DOCTYPE", ""))
        Set node(1) = xmlDoc.appendChild(xmlDoc.createNode(NODE_ELEMENT, "plist", ""))
        Set node(2) = node(1).appendChild(xmlDoc.createNode(NODE_ELEMENT, "array", ""))
        
        '�����l
        startRow = 2                                     '�擪�s�ԍ�
        maxRow = .Cells(1048576, eqNoClm).End(xlUp).Row  '�ŏI�s�ԍ�
        
        '��L�������Ƃ�XML�^�O�����o�͂���
        'mainCategory���^�O�o��(1��̂�)
        Set node(3) = node(2).appendChild(xmlDoc.createNode(NODE_ELEMENT, "dict", ""))
        Set node(4) = node(3).appendChild(xmlDoc.createNode(NODE_ELEMENT, "key", ""))
        node(4).Text = "items"
        Set node(4) = node(3).appendChild(xmlDoc.createNode(NODE_ELEMENT, "array", ""))
        
        'subCategory�֘A���^�O�o��
        For i = startRow To maxRow
            Set node(5) = node(4).appendChild(xmlDoc.createNode(NODE_ELEMENT, "dict", ""))
            Set node(6) = node(5).appendChild(xmlDoc.createNode(NODE_ELEMENT, "key", ""))
            node(6).Text = "countStoredImages"
            Set node(6) = node(5).appendChild(xmlDoc.createNode(NODE_ELEMENT, "integer", ""))
            node(6).Text = "0"  '�f�t�H���g�l
            Set node(6) = node(5).appendChild(xmlDoc.createNode(NODE_ELEMENT, "key", ""))
            node(6).Text = "images"
            Set node(6) = node(5).appendChild(xmlDoc.createNode(NODE_ELEMENT, "array", ""))
            Set node(6) = node(5).appendChild(xmlDoc.createNode(NODE_ELEMENT, "key", ""))
            node(6).Text = "subCategory"
            Set node(6) = node(5).appendChild(xmlDoc.createNode(NODE_ELEMENT, "string", ""))
            node(6).Text = .Cells(i, eqNoClm)   '�T�u�J�e�S����
        Next i
        
        'mainCategory�֘A���^�O�o��
        Set node(4) = node(3).appendChild(xmlDoc.createNode(NODE_ELEMENT, "key", ""))
        node(4).Text = "mainCategory"
        Set node(4) = node(3).appendChild(xmlDoc.createNode(NODE_ELEMENT, "string", ""))
        node(4).Text = "SampleList" '���C���J�e�S����
        Set node(4) = node(3).appendChild(xmlDoc.createNode(NODE_ELEMENT, "key", ""))
        node(4).Text = "subFolderMode"
        Set node(4) = node(3).appendChild(xmlDoc.createNode(NODE_ELEMENT, "integer", ""))
            node(4).Text = "0"  '�f�t�H���g�l
    End With
    
    xmlDoc.Save (tempFile)  '�ꎞ�t�@�C���ۑ�
    
    Open tempFile For Input As #1   '���̓t�@�C��(=�ꎞ�t�@�C��)
    Open fileName For Output As #2  '�o�̓t�@�C��(=Master�f�[�^)
    
    '�ꎞ�t�@�C���̏��胏�[�h���C������
    str = "<!DOCTYPE plist PUBLIC ""-//Apple//DTD PLIST 1.0//EN"" ""http://www.apple.com/DTDs/PropertyList-1.0.dtd"">"
    find = Array("<?DOCTYPE?>", "<plist>", "><")
    rep = Array(str, "<plist version=""1.0"">", ">" & vbLf & "<")
    
    '�ꎞ�t�@�C������Master�f�[�^�ɏ����o��
    Do Until EOF(1)
        Line Input #1, fileData
        
        For i = 0 To UBound(find)
            fileData = Replace(fileData, find(i), rep(i))
        Next i
        Print #2, fileData
    Loop
    Close
    
    If Dir(tempFile) <> "" Then
        Kill tempFile   '�ꎞ�t�@�C���폜
    End If
    
End Sub
Sub createZip()
    '**********************************
    '   ZIP�t�@�C���V�K�쐬����
    '
    '   Created by: Takashi Kawamoto
    '   Created on: 2023/9/8
    '**********************************
    
    Dim masterDir
    Dim fileName
    Dim toFolder
    Dim zipSrcFolder

    'Master�f�[�^(�ʐ^)�t�H���_
    masterDir = ThisWorkbook.Path & "\Master\SampleList"
    
    'Master�f�[�^�t�H���_���Ȃ��ꍇ�͐V�K�쐬����
    If Dir(masterDir, vbDirectory) = "" Then
        MkDir masterDir
    End If
    
    '��������摜�쐬
    fileName = masterDir & "\@readme.jpg"
    
    'JPG�t�@�C���V�K�쐬����
    Call createJPG(fileName)

    'ZIP���k�t�@�C���̕ۑ���t�H���_(��Master�f�[�^�t�H���_�uSampleList\�v�̈��̊K�w�t�H���_)���w�肷��
    toFolder = Mid(masterDir, 1, InStrRev(masterDir, "\") - 1)
    
    'ZIP���k�������t�H���_(=Master�f�[�^�t�H���_)���w�肷��
    zipSrcFolder = masterDir
    
    'ZIP���k�������t�H���_�����݂���ꍇ�̂݁AZIP���k���s��
    If Dir(zipSrcFolder, vbDirectory) <> "" Then
    
        'ZIP���k����
        Call ZipFileOrFolder2(zipSrcFolder)
    End If


End Sub
Sub createJPG(fName)
    '**********************************
    '   JPG�t�@�C���V�K�쐬����
    '
    '   Created by: Takashi Kawamoto
    '   Created on: 2023/9/8
    '**********************************

    Dim rg
    Dim cht As Chart
    Dim fileSize
    
    '��������G���A�R�s�[
    With ThisWorkbook.Sheets("Menu")
        Set rg = .Range(.Cells(10, 14), .Cells(20, 19))
    End With
    rg.CopyPicture
    
    '�ꎞ�f�[�^�쐬���摜�\��t����JPG�t�@�C���G�N�X�|�[�g
    Set cht = ThisWorkbook.Sheets("Menu").ChartObjects.Add(0, 0, rg.Width, rg.Height).Chart
    cht.Export fileName:=fName, filtername:="JPG"
    fileSize = FileLen(fName)
    
    Do Until FileLen(fName) > fileSize
        cht.Paste
        cht.Export fileName:=fName, filtername:="JPG"
        DoEvents
    Loop
    
    '�ꎞ�f�[�^�폜
    cht.Parent.Delete

End Sub
Sub editSampleID()
    '**********************************
    '   �T���v���Ɩ��ԍ��ݒ�E�ҏW
    '
    '   Created by: Takashi Kawamoto
    '   Created on: 2023/9/14
    '**********************************
    Dim strSID
    Dim tempFile
    Dim imgPlistPath_master
    Dim find
    Dim rep
    Dim fileData
    Dim i
    Dim wb As Workbook
    Dim oldFileName
    Dim oldFilePath
    Dim newFileName
    Dim newFilePath
    Dim reg As Object

    '�T���v���Ɩ��ԍ�����(����̂�)
    With ThisWorkbook.Sheets("SampleList")
        If .Cells(1, 1) = "" Then
             strSID = InputBox("�T���v���Ɩ��ԍ��H", , "EMCxx-xxxx")
        Else
             strSID = InputBox("�T���v���Ɩ��ԍ���ύX���܂����H", , .Cells(1, 1))
        End If
        If strSID <> "" Then
            .Cells(1, 1) = strSID
        Else
            Exit Sub
        End If
    End With
    
    '�yPLIST��(�ʐ^����)�zMaster�f�[�^: SampleList&img.plist
    imgPlistPath_master = ThisWorkbook.Path & "\Master\SampleList&img.plist"
    
    'PLIST-Master�f�[�^����mainCategory�����u�T���v���Ɩ��ԍ��v�ŏ㏑������
    tempFile = "c:\\temp\\temp.plist"   '�ꎞ�t�@�C��
    FileCopy imgPlistPath_master, tempFile
    
    Open tempFile For Input As #1               '���̓t�@�C��(=�ꎞ�t�@�C��)
    Open imgPlistPath_master For Output As #2   '�o�̓t�@�C��(=PLIST-Master�f�[�^)
    
    '�ꎞ�t�@�C���̏��胏�[�h���C������
    Set reg = CreateObject("VBScript.RegExp")
    With reg
        .Pattern = "EMC[0-9][0-9]-[0-9][0-9][0-9][0-9]"
        .IgnoreCase = True
        .Global = True
    End With
    find = Array("<string>SampleList</string>")
    rep = Array("<string>" & strSID & "</string>")
    
    '�ꎞ�t�@�C������Master�f�[�^�ɏ����o��
    Do Until EOF(1)
        Line Input #1, fileData
        
        For i = 0 To UBound(find)
            fileData = reg.Replace(fileData, strSID)
            fileData = Replace(fileData, find(i), rep(i))
        Next i
        Print #2, fileData
    Loop
    Close
    
    If Dir(tempFile) <> "" Then
        Kill tempFile   '�ꎞ�t�@�C���폜
    End If
    
    'Master(Excel)�ۑ�
    Set wb = ThisWorkbook
    If wb.ReadOnly = True Then
        oldFileName = ThisWorkbook.Name
        oldFilePath = ThisWorkbook.Path & "\" & ThisWorkbook.Name
        newFileName = "@" & ThisWorkbook.Name
        newFilePath = ThisWorkbook.Path & "\@" & ThisWorkbook.Name
        ThisWorkbook.SaveAs newFilePath
        If Dir(oldFilePath) <> "" Then
            If Dir(ThisWorkbook.Path & "\old", vbDirectory) = "" Then
                MkDir ThisWorkbook.Path & "\old"
            End If
            Name oldFilePath As ThisWorkbook.Path & "\old\�y���z" & oldFileName
        End If
        MsgBox ("Master(Excel)�t�@�C�����ǂݎ���p�̂��ߕʖ��ŕۑ����܂���" & Chr(10) & newFileName)
    Else
        ThisWorkbook.Save
    End If
    
    '�����I��
    MsgBox ("Completed")
End Sub
Sub createCarryOutData()
    '**********************************
    '   �n���f�B���o�f�[�^�쐬
    '
    '   Created by: Takashi Kawamoto
    '   Created on: 2023/9/6
    '**********************************

    Dim strSID
    Dim strDate
    Dim strTestRoomNo
    Dim strReqNo
    Dim fileName
    Dim maxClm
    Dim plistPath_target
    Dim plistPath_master
    Dim imgPlistPath_target
    Dim imgPlistPath_master
    Dim zipPath_target
    Dim zipPath_master
    Dim folderPath_target
    Dim folderPath_master, folderPath_master2
    Dim strYN
    Dim toFolder
    Dim zipSrcFolder
    Dim tempFile
    Dim find
    Dim rep
    Dim fileData
    Dim i
    Dim wb As Workbook
    Dim oldFileName, newFileName
    Dim oldFilePath, newFilePath
    Dim FSO As Object
    Dim arr_ReqNo As Variant
    Dim maxRow, maxRow3
    Dim fromRow
    Dim toRow
    Dim cntRow
    Dim matchRow
    
    '�T���v���Ɩ��ԍ�����(����̂�)
    With ThisWorkbook.Sheets("SampleList")
        If .Cells(1, 1) = "" Then
            .Cells(1, 1) = InputBox("�T���v���Ɩ��ԍ��H", , "EMCxx-xxxx")
        End If
        strSID = .Cells(1, 1)
    End With
    
    '���t���̓f�[�^�擾
    strDate = InputBox("���tyymmdd�H", , Format(Date, "yymmdd"))
    If strDate = "" Then
        Exit Sub
    End If
    
    '�ݔ����̓f�[�^�擾
    strTestRoomNo = InputBox("�ݔ����H", , "ALCx")
    If strTestRoomNo = "" Then
        Exit Sub
    End If
    
    '���o�������ړ��̓f�[�^�擾
    With ThisWorkbook.Sheets("SampleList")
        maxClm = .Cells(1, 16384).End(xlToLeft).Column '�`�F�b�N�{�b�N�X���G���A�̍ŏI��ԍ��擾
        
        '�`�F�b�N�{�b�N�X���G���A�̊e�񂲂Ƃɏ������J��Ԃ�
        If maxClm >= 14 Then
            For i = 14 To maxClm
                strReqNo = strReqNo & "," & .Cells(1, i)    '�����������ږ����J���}�łȂ��Ă���
            Next i
            strReqNo = Replace(Mid(strReqNo, 2), " ", "")
        End If
    End With
    
    '�}�X�^�[�Ƀ`�F�b�N�{�b�N�X���(�������ږ�)�����݂���ꍇ�̂݁A���̓{�b�N�X��\������
    If strReqNo <> "" Then
        strReqNo = InputBox("�����o��������������(�ߋ����{��)������Ύw�肵�Ă��������B" & Chr(10) & Chr(10) & "���X�}�z���삪�d���Ȃ�ׁA" & Chr(10) & "�u�w��Ȃ�(��)�v�܂��́u�K�v�ŏ����̎w��v�ɂ��鎖�B", , strReqNo)
    End If
    
    '���o�f�[�^���FSampleList_�u���t�v_�u�ݔ����v.plist
    fileName = "SampleList_" & strDate & "_" & strTestRoomNo
    
    '�yPLIST��(�ʐ^�Ȃ�)�zMaster�f�[�^: SampleList.plist
    plistPath_target = ThisWorkbook.Path & "\" & fileName & ".plist"
    plistPath_master = ThisWorkbook.Path & "\Master\SampleList.plist"
    
    '�yPLIST��(�ʐ^����)�zMaster�f�[�^: SampleList&img.plist
    imgPlistPath_target = ThisWorkbook.Path & "\" & fileName & "&img.plist"
    imgPlistPath_master = ThisWorkbook.Path & "\Master\SampleList&img.plist"
    
    '�yZIP�t�@�C�����zMaster�f�[�^: SampleLost.zip
    zipPath_target = ThisWorkbook.Path & "\" & fileName & ".zip"
    zipPath_master = ThisWorkbook.Path & "\Master\SampleList.zip"
    
    '�yZIP�Ώۃt�H���_���zMaster�f�[�^: SampleLost\
    folderPath_target = ThisWorkbook.Path & "\" & fileName
    folderPath_master = ThisWorkbook.Path & "\Master\SampleList\"
    folderPath_master2 = ThisWorkbook.Path & "\Master\SampleList"
    
    '�y�ǉ������zPLIST-Master�f�[�^����mainCategory�����u�T���v���Ɩ��ԍ��v�ɒu��������
    tempFile = "c:\\temp\\temp.plist"   '�ꎞ�t�@�C��
    FileCopy imgPlistPath_master, tempFile
    
    Open tempFile For Input As #1               '���̓t�@�C��(=�ꎞ�t�@�C��)
    Open imgPlistPath_master For Output As #2   '�o�̓t�@�C��(=PLIST-Master�f�[�^)
    
    '�ꎞ�t�@�C���̏��胏�[�h���C������
    find = Array("<string>SampleList</string>")
    rep = Array("<string>" & strSID & "</string>")
    
    '�ꎞ�t�@�C������Master�f�[�^�ɏ����o��
    Do Until EOF(1)
        Line Input #1, fileData
        
        For i = 0 To UBound(find)
            fileData = Replace(fileData, find(i), rep(i))
        Next i
        Print #2, fileData
    Loop
    Close
    
    If Dir(tempFile) <> "" Then
        Kill tempFile   '�ꎞ�t�@�C���폜
    End If
    
    'zip�t�@�C��������ꍇ�A�uzip�vMaster�f�[�^�Ɓu&img.plist�vMaster�f�[�^���R�s�[���Ď��o�f�[�^���쐬����
    If Dir(zipPath_master) <> "" Then
   
        '�����t�@�C�����Ȃ��ꍇ
        If Dir(zipPath_target) = "" And Dir(imgPlistPath_target) = "" Then
            
            '�u&img.plist�v���R�s�[
            FileCopy imgPlistPath_master, imgPlistPath_target
            
            'zip�t�@�C���𓀏���
            Call unzipFile(imgPlistPath_master)
            
            '�𓀃t�H���_���l�[�� & zip�Ώۃt�H���_���k
            If Dir(folderPath_target, vbDirectory) <> "" Then
                With CreateObject("Scripting.FileSystemObject")
                    .DeleteFolder folderPath_target
                End With
            End If
            
            'Target�t�H���_���Ȃ��ꍇ�͐V�K�쐬����
            If Dir(folderPath_target, vbDirectory) = "" Then
                MkDir folderPath_target
            End If
            Set FSO = CreateObject("Scripting.FileSystemObject")
            FSO.CopyFolder folderPath_master2, folderPath_target
            Set FSO = Nothing
            
            'zip���k����
            Call ZipFileOrFolder(folderPath_target)
            
            '�𓀃t�H���_�폜(�t�H���_�����݂���ꍇ�̂�)
            If Dir(folderPath_target, vbDirectory) <> "" Then
                With CreateObject("Scripting.FileSystemObject")
                    .DeleteFolder folderPath_target
                End With
            End If
        
        '�����t�@�C��������ꍇ
        Else
        
            '�m�F���b�Z�[�W�\��
            strYN = MsgBox("�ȉ��̃t�@�C�����㏑�����܂����H" & Chr(10) & imgPlistPath_target & Chr(10) & zipPath_target, vbYesNo)
            
            '�uYes�v�̏ꍇ
            If strYN = vbYes Then
            
                '�u&img.plist�v���R�s�[
                FileCopy imgPlistPath_master, imgPlistPath_target
                
                'zip�t�@�C���𓀏���
                Call unzipFile(imgPlistPath_master)
                
                '�𓀃t�H���_���l�[�� & zip�Ώۃt�H���_���k
                If Dir(folderPath_target, vbDirectory) <> "" Then
                    With CreateObject("Scripting.FileSystemObject")
                        .DeleteFolder folderPath_target
                    End With
                End If
                
                'Target�t�H���_���Ȃ��ꍇ�͐V�K�쐬����
                If Dir(folderPath_target, vbDirectory) = "" Then
                    MkDir folderPath_target
                End If
                
                Set FSO = CreateObject("Scripting.FileSystemObject")
                FSO.CopyFolder folderPath_master2, folderPath_target
                Set FSO = Nothing
                
                'zip���k����
                Call ZipFileOrFolder(folderPath_target)
                
                '�𓀃t�H���_�폜(�t�H���_�����݂���ꍇ�̂�)
                If Dir(folderPath_target, vbDirectory) <> "" Then
                    With CreateObject("Scripting.FileSystemObject")
                        .DeleteFolder folderPath_target
                    End With
                End If
                
            '�uNo�v�̏ꍇ
            Else
                MsgBox ("�����𒆎~���܂�")
                Exit Sub
            End If
            
        End If
        
        '���o�f�[�^�̃`�F�b�N�{�b�N�X�����w�莎�����ڂ݂̂ɍX�V����
        With ThisWorkbook.Sheets("wk_Eno")
            .Cells(1, 3) = imgPlistPath_target  '���o�f�[�^�̃t�H���_�p�X���w��
        End With
        
        'PLIST�f�[�^�Ǎ�����
        Call loadImgPlist(20, 1)
        
        '�u�g�p�@��wk�V�[�g�v
        With ThisWorkbook.Sheets("wk_cb")
        
            '���V�[�g�Ƀ`�F�b�N�{�b�N�X��񂪂���ꍇ�̂ݏ�������
            maxRow = .Cells(1048576, 2).End(xlUp).Row
            If maxRow >= 20 Then
            
                '�����l�Z�b�g
                maxRow3 = 19    '�ꎞ�G���A�̍ŏI�s�ԍ�
                matchRow = 0
                fromRow = 0
                .Range(.Columns(9), .Columns(12)).Clear '�����o���G���A(�ꎞ�G���A)�N���A
                
                '���͎����������ڏ�񂪋󗓂̏ꍇ�A�����o���G���A(�����f�[�^�G���A)�N���A�������f�[�^���̃`�F�b�N�{�b�N�X�����폜����
                If strReqNo = "" Then
                    .Range(.Columns(1), .Columns(4)).Clear
                    
                '���͎����������ڏ�񂪎w�肠��̏ꍇ
                Else
                    arr_ReqNo = Split(strReqNo, ",")    '���͎����������ڏ����J���}�ŕ����˔z��i�[
                    
                    '���͎����������ڂ��Ƃɏ������J��Ԃ�
                    For i = 0 To UBound(arr_ReqNo)
                        On Error Resume Next
                        matchRow = WorksheetFunction.Match(arr_ReqNo(i), .Columns(3), 0)    '�����f�[�^���̃`�F�b�N�{�b�N�X��񂩂���͎������ږ��ƈ�v����s�ԍ����擾
                        On Error GoTo 0
                        
                        '��v�s������ꍇ
                        If matchRow <> 0 Then
                        
                            '�}�b�`���O���G���[�����ꍇ�AmatchRow�������Ȃ�(0�ɂȂ�Ȃ�)�ˏ������X���[����
                            If fromRow = matchRow Then
                                '�����Ȃ�
                                
                            '�}�b�`���O���G���[���Ȃ������ꍇ
                            Else
                                fromRow = matchRow                              '�}�b�`�G���A�J�n�s�ԍ�
                                toRow = .Cells(matchRow, 4).End(xlDown).Row - 1 '�}�b�`�G���A�I���s�ԍ�
                                If toRow > maxRow Then
                                    toRow = maxRow
                                End If
                                cntRow = toRow - fromRow + 1                    '�}�b�`�G���A�s��
                                .Range(.Cells(fromRow, 1), .Cells(toRow, 4)).Copy Destination:=.Cells(maxRow3 + 1, 9)    '�R�s�[��ˈꎞ�G���A�̖���
                                maxRow3 = maxRow3 + cntRow  '�ꎞ�G���A�̍ŏI�s�ԍ����X�V
                            End If
                        End If
                    Next i
    
                    '�ꎞ�G���A��Ǝ����f�[�^������ւ�
                    .Range(.Columns(9), .Columns(12)).Copy Destination:=.Cells(1, 1)
                    
                End If
                    
                '�����f�[�^PLIST�ۑ�
                Call applyPlist
            
            End If
        End With

    'zip�t�@�C�����Ȃ��ꍇ�A�u.plist�vMaster�f�[�^���R�s�[���Ď��o�f�[�^���쐬����
    Else
        FileCopy plistPath_master, plistPath_target
    End If
    
    'Master(Excel)�ۑ�
    Set wb = ThisWorkbook
    If wb.ReadOnly = True Then
        oldFileName = ThisWorkbook.Name
        oldFilePath = ThisWorkbook.Path & "\" & ThisWorkbook.Name
        newFileName = "@" & ThisWorkbook.Name
        newFilePath = ThisWorkbook.Path & "\@" & ThisWorkbook.Name
        ThisWorkbook.SaveAs newFilePath
        If Dir(oldFilePath) <> "" Then
            If Dir(ThisWorkbook.Path & "\old", vbDirectory) = "" Then
                MkDir ThisWorkbook.Path & "\old"
            End If
            Name oldFilePath As ThisWorkbook.Path & "\old\�y���z" & oldFileName
        End If
        MsgBox ("Master(Excel)�t�@�C�����ǂݎ���p�̂��ߕʖ��ŕۑ����܂���" & Chr(10) & newFileName)
    Else
        ThisWorkbook.Save
    End If

    
    '�I������
    MsgBox ("���o�f�[�^�o�͊���")
End Sub
Sub applyCarryInData()
    '**********************************
    '   �n���f�B�����f�[�^����
    '
    '   Created by: Takashi Kawamoto
    '   Created on: 2023/9/6
    '**********************************
    
    Dim startRow
    Dim startColumn
    Dim plistPath_target
    Dim plistPath_master
    Dim imgPlistPath_target
    Dim imgPlistPath_master
    Dim zipPath_target
    Dim folderPath_target
    Dim folderPath_master
    Dim isMaster
    Dim res
    Dim wb As Workbook
    Dim oldFileName, newFileName
    Dim oldFilePath, newFilePath
    
    plistPath_master = ThisWorkbook.Path & "\Master\SampleList.plist"         '����PLIST-Master�f�[�^(.plist)
    imgPlistPath_master = ThisWorkbook.Path & "\Master\SampleList&img.plist"  'PLIST-Master�f�[�^(&img.plist)
    
    'PLIST-�����f�[�^�Ǎ�����
    startRow = 20
    startColumn = 5
    isMaster = False
    
    '�w�����b�Z�[�W�\��
    MsgBox ("�����f�[�^���w�肵�Ă�������")
    
    '�t�@�C���I���_�C�A���O�\��
    Call selectFile(startRow, startColumn, isMaster)
    
    '�I���t�@�C�����Ȃ��ꍇ�A�������I������
    If ThisWorkbook.Sheets("wk_Eno").Cells(1, startColumn + 2) = "" Then
        Exit Sub
    End If
    
    '�w�肵�������f�[�^��Master(Excel)�t�@�C���Ɠ���t�H���_���ɑ��݂��Ȃ��ꍇ�A�������I������
    If Left(ThisWorkbook.Sheets("wk_Eno").Cells(1, startColumn + 2), InStrRev(ThisWorkbook.Sheets("wk_Eno").Cells(1, startColumn + 2), "\") - 1) <> ThisWorkbook.Path Then
        MsgBox ("�����f�[�^��Master(Excel)�t�@�C���Ɠ����t�H���_���̂��̂��w�肵�Ă�������" & Chr(10) & "Master(Excel)�t�@�C���ꏊ: " & ThisWorkbook.Path)
        Exit Sub
    End If
    
    'PLIST-�����f�[�^�Ǎ�����
    Call loadImgPlist(startRow, startColumn)
    
    '�y�ǉ��zPLIST-�����f�[�^-�T���v���Ɩ��ԍ��`�F�b�N
    If ThisWorkbook.Sheets("wk_Eno").Cells(startRow, 7) <> ThisWorkbook.Sheets("SampleList").Cells(1, 1) Then
        MsgBox ("�����f�[�^�̃T���v���Ɩ��ԍ�����v���܂���B�����𒆎~���܂��B")
        Exit Sub
    End If
    
    'Master�f�[�^�Ǎ�
    'PLIST-Master�f�[�^(&img.plist)������ꍇ�A���f�[�^�p�X���Z�b�g����
    If Dir(imgPlistPath_master) <> "" Then
        ThisWorkbook.Sheets("wk_Eno").Cells(1, 3) = imgPlistPath_master
        
    'PLIST-Master�f�[�^(&img.plist)���Ȃ��ꍇ�A����PLIST-Master�f�[�^(.plist)������΁A���f�[�^�p�X���Z�b�g����
    ElseIf Dir(plistPath_master) <> "" Then
        ThisWorkbook.Sheets("wk_Eno").Cells(1, 3) = plistPath_master
    End If
        
    'PLIST-Master�f�[�^�Ǎ�����
    startRow = 20
    startColumn = 1
    Call loadImgPlist(startRow, startColumn)
    
    'ZIP-Master�f�[�^�𓀏���
    Call unzipFileMaster
    
    'PLIST-Master-�����f�[�^��r����
    Call comparePlist
    
    'ZIP-�����f�[�^�𓀏���
    Call unzipFileUpdated
    
    'PLIST���}�[�W����
    Call mergePlist
    
    'PLIST��ZIP�X�V���f����
    Call applyPlistAndZip

    'Master(Excel)�X�V���f����
    Call applySampleList
    
    '����PLIST-Master�f�[�^�폜(�t�@�C�������݂���ꍇ�̂�)
    If Dir(plistPath_master) <> "" Then
        Kill plistPath_master
    End If
    
    '����PLIST-���o�f�[�^�폜(�t�@�C�������݂���ꍇ�̂�)
    plistPath_target = Replace(ThisWorkbook.Sheets("wk_Eno").Cells(1, 7), "&img.plist", ".plist")
    If Dir(plistPath_target) <> "" Then
        Kill plistPath_target
    End If
    
    '�����f�[�^�𓀃t�H���_�폜(�t�H���_�����݂���ꍇ�̂�)
    folderPath_target = Replace(ThisWorkbook.Sheets("wk_Eno").Cells(1, 7), "&img.plist", "")
    folderPath_master = ThisWorkbook.Path & "\Master\SampleList"
    
    '�����f�[�^����Master�f�[�^���ƈقȂ�ꍇ�̂ݏ�������
    If folderPath_target <> folderPath_master Then
        If Dir(folderPath_target, vbDirectory) <> "" Then
            With CreateObject("Scripting.FileSystemObject")
                .DeleteFolder folderPath_target
            End With
        End If
    End If
    
    '�uSampleList�v�t�H���_�́AMaster(Excel)���̊e�T���l�C���ʐ^�ɂ��ꂼ�ꃊ���N���ꂽ���ʐ^���ۑ�����Ă��邽�ߍ폜���Ȃ�
'    If Dir(folderPath_master, vbDirectory) <> "" Then
'        With CreateObject("Scripting.FileSystemObject")
'            .DeleteFolder folderPath_master
'        End With
'    End If

    '�����f�[�^�폜(�t�@�C�������݂���ꍇ�̂�)
    imgPlistPath_target = ThisWorkbook.Sheets("wk_Eno").Cells(1, 7)
    zipPath_target = Replace(ThisWorkbook.Sheets("wk_Eno").Cells(1, 7), "&img.plist", ".zip")
    
    '�����f�[�^����Master�f�[�^���ƈقȂ�ꍇ�̂ݏ�������
    If imgPlistPath_target <> imgPlistPath_master Then
    
        '�m�F���b�Z�[�W�\��
        res = MsgBox("�����f�[�^���폜���܂����H" & Chr(10) & imgPlistPath_target & Chr(10) & zipPath_target, vbYesNo)
        
        '�uYes�v�̏ꍇ
        If res = vbYes Then
            If Dir(imgPlistPath_target) <> "" Then
                Kill imgPlistPath_target    '&img.plist
            End If
            If Dir(zipPath_target) <> "" Then
                Kill zipPath_target         'zip
            End If
        End If
    End If
    
    'Master(Excel)�ۑ�
    Set wb = ThisWorkbook
    If wb.ReadOnly = True Then
        oldFileName = ThisWorkbook.Name
        oldFilePath = ThisWorkbook.Path & "\" & ThisWorkbook.Name
        newFileName = "@" & ThisWorkbook.Name
        newFilePath = ThisWorkbook.Path & "\@" & ThisWorkbook.Name
        ThisWorkbook.SaveAs newFilePath
        If Dir(oldFilePath) <> "" Then
            If Dir(ThisWorkbook.Path & "\old", vbDirectory) = "" Then
                MkDir ThisWorkbook.Path & "\old"
            End If
            Name oldFilePath As ThisWorkbook.Path & "\old\�y���z" & oldFileName
        End If
        MsgBox ("Master(Excel)�t�@�C�����ǂݎ���p�̂��ߕʖ��ŕۑ����܂���" & Chr(10) & newFileName)
    Else
        ThisWorkbook.Save
    End If
    
    '�I������
    MsgBox ("�����f�[�^��������")
End Sub



