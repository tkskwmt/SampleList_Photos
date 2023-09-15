Attribute VB_Name = "Module2"
Option Explicit
Sub selectFileMaster()
    '**********************************
    '   PLIST-Master�f�[�^�I������
    '
    '   Created by: Takashi Kawamoto
    '   Created on: 2023/9/6
    '**********************************
    
    Dim startRow
    Dim startColumn
    Dim isMaster
    
    '��������
    startRow = 20
    startColumn = 1
    isMaster = True
    
    '�t�@�C���I���_�C�A���O
    Call selectFile(startRow, startColumn, isMaster)
    
    '�t�@�C�����I������Ȃ������ꍇ�A�������I������
    If ThisWorkbook.Sheets("wk_Eno").Cells(1, startColumn + 2) = "" Then
        Exit Sub
    End If
    
    'PLIST-Master�f�[�^�Ǎ�����
    Call loadImgPlist(startRow, startColumn)
    
    'ZIP-Master�f�[�^�𓀏���
    Call unzipFileMaster
    
    '�I������
    MsgBox ("Completed")
End Sub
Sub selectFileUpdated()
    '**********************************
    '   PLIST-�����f�[�^�I������
    '
    '   Created by: Takashi Kawamoto
    '   Created on: 2023/9/6
    '**********************************
    
    Dim startRow
    Dim startColumn
    Dim isMaster
    
    '��������
    startRow = 20
    startColumn = 5
    isMaster = False
    
    '�t�@�C���I���_�C�A���O
    Call selectFile(startRow, startColumn, isMaster)
    
    '�t�@�C�����I������Ȃ������ꍇ�A�������I������
    If ThisWorkbook.Sheets("wk_Eno").Cells(1, startColumn + 2) = "" Then
        Exit Sub
    End If
    
    'PLIST-�����f�[�^�Ǎ�����
    Call loadImgPlist(startRow, startColumn)
    
    'PLIST-Master-�����f�[�^��r����
    Call comparePlist
    
    'ZIP-�����f�[�^�𓀏���
    Call unzipFileUpdated
        
    '�I������
    MsgBox ("Completed")
End Sub
Sub selectFile(startRow, startColumn, isMaster)
    '**********************************
    '   �t�@�C���I���_�C�A���O
    '
    '   Created by: Takashi Kawamoto
    '   Created on: 2023/9/6
    '**********************************
    
    Dim preFileName
    Dim defaultFolderName
    
    With ThisWorkbook.Sheets("wk_Eno")
    
        '�o�̓G���A�N���A
        .Range(.Cells(startRow, startColumn), .Cells(1048576, startColumn + 3)).Clear
        
        '�O��I���t�H���_�p�X�擾
        preFileName = .Cells(1, startColumn + 2)
    End With

    With Application.FileDialog(msoFileDialogOpen)
    
        '�O��I���t�H���_�p�X��񂪂���ꍇ
        If preFileName <> "" Then
        
            '�����t�H���_�ݒ�F�O��I���t�H���_�p�X
            .InitialFileName = preFileName
            
            '�I���t�H���_�p�X�ݒ�p�Z���N���A
            ThisWorkbook.Sheets("wk_Eno").Cells(1, startColumn + 2).ClearContents
        
        '�O��I���t�H���_�p�X��񂪂Ȃ��ꍇ
        Else
            
            '�����t�H���_�ݒ�F�{Master(Excel)�i�[�t�H���_�p�X
            .InitialFileName = ThisWorkbook.Path
        End If
        
        '�Ώۃt�@�C����ސݒ�F�u&img.plist�v�u.plist�v
        .Filters.Clear
        .Filters.Add "&img.plist", "*.plist"
        
        '�_�C�A���O���\�����ꂽ��I���t�@�C���p�X���擾����
        If .Show = True Then
            
            'Master�f�[�^�̏ꍇ
            If isMaster = True Then
                
                '�I���t�@�C���p�X���{Master(Excel)�i�[�t�H���_���́uMaster�v�t�H���_�ƈ�v����A���A�I���t�@�C�����u.plist�v�ɊY������ꍇ�̂ݏ�������
                If Left(.SelectedItems(1), InStrRev(.SelectedItems(1), "\") - 1) = ThisWorkbook.Path & "\Master" And InStr(.SelectedItems(1), ".plist") > 0 Then
                    ThisWorkbook.Sheets("wk_Eno").Cells(1, startColumn + 2) = .SelectedItems(1)
                    
                '��L�𖞂����Ȃ��ꍇ�A�������I������
                Else
                    MsgBox ("�{Master(Excel)�i�[�t�H���_���́uMaster�v�t�H���_���ɂ���uSampleList.plst�v�܂��́uSampleList&img.plist�v��I�����Ă�������")
                    Exit Sub
                End If
            
            '�����f�[�^�̏ꍇ
            Else
            
                '�I���t�@�C���p�X���{Master(Excel)�i�[�t�H���_�ƈ�v����A���A�I���t�@�C�����u&img.plist�v�ɊY������ꍇ�̂ݏ�������
                If Left(.SelectedItems(1), InStrRev(.SelectedItems(1), "\") - 1) = ThisWorkbook.Path And InStr(.SelectedItems(1), "&img.plist") > 0 Then
                    ThisWorkbook.Sheets("wk_Eno").Cells(1, startColumn + 2) = .SelectedItems(1)
                    
                '��L�𖞂����Ȃ��ꍇ�A�������I������
                Else
                    MsgBox ("�{Master(Excel)�i�[�t�H���_���́u&img.plist�v�t�@�C����I�����Ă�������")
                    Exit Sub
                End If
            End If
                    
        End If
    End With

End Sub
Sub loadImgPlist(startRow, startColumn)
    '**********************************
    '   PLIST�f�[�^�Ǎ�����
    '
    '   Created by: Takashi Kawamoto
    '   Created on: 2023/9/6
    '**********************************
    
    Dim myDom As MSXML2.DOMDocument60
    Dim myNodeList As IXMLDOMNodeList
    Dim myNode As IXMLDOMNode
    Dim myChildNode As IXMLDOMNode
    Dim i
    Dim imgPlistPath
    Dim maxRow
    Dim mainCategoryCount
    Dim subCategoryCount
    Dim array1 As Variant
    Dim myNode2
    Dim f_done
    
    '�u�@��ԍ�wk�V�[�g�v�����o������
    With ThisWorkbook.Sheets("wk_Eno")
    
        'PLIST�t�@�C���p�X�擾
        imgPlistPath = .Cells(1, startColumn + 2)
        
        '�t�@�C�����݃`�F�b�N
        If Dir(imgPlistPath) = "" Then
            MsgBox (imgPlistPath & " doesn't exist")
            Exit Sub
        End If
        
        'XML�Ǎ�����
        Set myDom = New MSXML2.DOMDocument60
        With myDom
            .SetProperty "ProhibitDTD", False
            .async = False
            .resolveExternals = False
            .validateOnParse = False
            .Load xmlSource:=imgPlistPath
        End With
        Set myNodeList = myDom.SelectNodes("/plist")
        
        '�����o���G���A�N���A
        .Range(.Cells(startRow, startColumn), .Cells(1048576, startColumn + 3)).Clear
        
        '�����l
        i = startRow
        mainCategoryCount = 0
        subCategoryCount = 0
        
        'XML�^�O�̏����ɉ����ď������� (1���:�\�[�g���d�ݕt��, 2���: XML�^�O���, 3���: �f�[�^�l
        For Each myNode In myNodeList
        
            array1 = Split(myNode.ChildNodes(0).Text, " ")
            
            For Each myNode2 In array1
            
                Select Case myNode2
                
                Case "mainCategory", "subFolderMode", "subCategory", "countStoredImages", "imageFile"
                    
                    '1��ڏ����o��
                    Select Case myNode2
                    Case "mainCategory"
                        .Cells(i, startColumn) = mainCategoryCount * 10000
                        mainCategoryCount = mainCategoryCount + 1
                        subCategoryCount = 0
                    Case "subFolderMode"
                        .Cells(i, startColumn) = (mainCategoryCount - 1) * 10000 + 0.1
                    Case "subCategory"
                        .Cells(i, startColumn) = 1 + mainCategoryCount * 10000 + subCategoryCount * 10
                        subCategoryCount = subCategoryCount + 1
                    Case "countStoredImages"
                        .Cells(i, startColumn) = 2 + mainCategoryCount * 10000 + subCategoryCount * 10
                    Case "imageFile"
                        .Cells(i, startColumn) = 3 + mainCategoryCount * 10000 + subCategoryCount * 10
                    End Select
                    
                    '2��ڏ����o��
                    .Cells(i, startColumn + 1) = myNode2
                    
                Case "items", "images"
                    'none
                    
                Case Else
                    
                    '3��ڏ����o��
                    '�uimageFile�v�^�O���̏ꍇ�̂݁A�ʐ^�������̏ꍇ�͎ʐ^�����J���}�łȂ��ď����ɏ����o��
                    If .Cells(i, startColumn + 1) = "imageFile" Then
                        If .Cells(i - 1, startColumn + 1) = "imageFile" Then
                            .Cells(i - 1, startColumn + 2) = .Cells(i - 1, startColumn + 2) & "," & myNode2
                            .Cells(1, startColumn) = ""
                            .Cells(1, startColumn + 1) = ""
                        Else
                            .Cells(i, startColumn + 2) = myNode2
                            i = i + 1
                        End If
                    
                    '�umainCategory�v�usubCategory�v�ucountStoredImages�v�^�O���̏ꍇ�A�����Ƀf�[�^�l�������o��
                    Else
                        .Cells(i, startColumn + 2) = myNode2
                        i = i + 1
                    End If
                    
                    '�ŏ���mainCategory���̂ݏ�������
                    If mainCategoryCount >= 1 And .Cells(i - 1, startColumn + 1) = "subFolderMode" Then
                        Exit For
                    End If
                    
                End Select
            Next
        Next
        
        '�\�[�g����
        maxRow = .Cells(1048576, startColumn).End(xlUp).Row
        
        '�Ώۍs���Ȃ��ꍇ�A�������I������
        If maxRow < startRow Then
            Exit Sub
        End If
        
        '�\�[�g�L�[: 1���
        .Sort.SortFields.Clear
        .Sort.SortFields.Add2 Key:=.Range(.Cells(startRow, startColumn), .Cells(maxRow, startColumn)), SortOn:=xlSortOnValues, Order:=xlAscending, DataOption:=xlSortNormal
        With .Sort
            .SetRange Range(Cells(startRow, startColumn), Cells(maxRow, startColumn + 3))
            .Header = xlGuess
            .MatchCase = False
            .Orientation = xlTopToBottom
            .SortMethod = xlPinYin
            .Apply
        End With
        
        '�usubCategory�v�^�O���ɁuimageFile�v�^�O���Ȃ��ꍇ�́A�ʐ^��񂪋�́uimageFile�v�s��ǉ�����
        For i = startRow To maxRow * 2
        
            '1��ڃf�[�^���󗓂̏ꍇ�A�������I������
            If .Cells(i, startColumn) = "" Then
                Exit For
            End If
            
            '�ʐ^������\���ucountStoredImages�v�f�[�^��0(=�ʐ^��񂪋�)�̏ꍇ�̂ݏ�������
            If .Cells(i, startColumn + 1) = "countStoredImages" And .Cells(i, startColumn + 2) = 0 Then
            
                '1�s�}��
                .Range(.Cells(i + 1, startColumn), .Cells(i + 1, startColumn + 3)).Insert Shift:=xlDown, CopyOrigin:=xlFormatFromLeftOrAbove
                .Cells(i + 1, startColumn) = .Cells(i, startColumn) + 1 '1��ڏ��Z�b�g
                .Cells(i + 1, startColumn + 1) = "imageFile"            '2��ڏ��Z�b�g(3,4��ڂ͋�)
            End If
            
        Next i

        '�\�[�g����(2���)
        maxRow = .Cells(1048576, startColumn).End(xlUp).Row
        
        '�\�[�g�L�[: 1���
        .Sort.SortFields.Clear
        .Sort.SortFields.Add2 Key:=.Range(.Cells(startRow, startColumn), .Cells(maxRow, startColumn)), SortOn:=xlSortOnValues, Order:=xlAscending, DataOption:=xlSortNormal
        With .Sort
            .SetRange Range(Cells(startRow, startColumn), Cells(maxRow, startColumn + 3))
            .Header = xlGuess
            .MatchCase = False
            .Orientation = xlTopToBottom
            .SortMethod = xlPinYin
            .Apply
        End With
    
    End With
    
    '�u�g�p�@��wk�V�[�g�v�����o������
    With ThisWorkbook.Sheets("wk_cb")
            
        '�����o���G���A�N���A
        .Range(.Cells(startRow, startColumn), .Cells(1048576, startColumn + 3)).Clear
        
        '�����l
        i = startRow
        mainCategoryCount = 0
        subCategoryCount = 0
        f_done = 0
        
        'XML�^�O�̏����ɉ����ď������� (1���:�\�[�g���d�ݕt��, 2���: XML�^�O���, 3���: �f�[�^�l
        For Each myNode In myNodeList
        
            array1 = Split(myNode.ChildNodes(0).Text, " ")
            
            For Each myNode2 In array1
            
                Select Case myNode2
                
                Case "mainCategory", "subFolderMode", "subCategory", "countStoredImages", "imageFile"
                    
                    '1��ڏ����o��
                    Select Case myNode2
                    Case "mainCategory"
                        .Cells(i, startColumn) = mainCategoryCount * 10000
                        mainCategoryCount = mainCategoryCount + 1
                        subCategoryCount = 0
                    Case "subFolderMode"
                        .Cells(i, startColumn) = (mainCategoryCount - 1) * 10000 + 0.1
                    Case "subCategory"
                        .Cells(i, startColumn) = 1 + mainCategoryCount * 10000 + subCategoryCount * 10
                        subCategoryCount = subCategoryCount + 1
                    Case "countStoredImages"
                        .Cells(i, startColumn) = 2 + mainCategoryCount * 10000 + subCategoryCount * 10
                    Case "imageFile"
                        .Cells(i, startColumn) = 3 + mainCategoryCount * 10000 + subCategoryCount * 10
                    End Select
                    
                    '2��ڏ����o��
                    .Cells(i, startColumn + 1) = myNode2
                    
                    '4��ڏ����o���ˁumainCategory�v���ʃ}�[�N�ǉ�
                    If myNode2 = "mainCategory" Then
                        .Cells(i, startColumn + 3) = "@"
                    End If
                    
                Case "items", "images"
                    'none
                    
                Case Else
                    
                    '3��ڏ����o��
                    '�uimageFile�v�^�O���̏ꍇ�̂݁A�ʐ^�������̏ꍇ�͎ʐ^�����J���}�łȂ��ď����ɏ����o��
                    If .Cells(i, startColumn + 1) = "imageFile" Then
                        If .Cells(i - 1, startColumn + 1) = "imageFile" Then
                            .Cells(i - 1, startColumn + 2) = .Cells(i - 1, startColumn + 2) & "," & myNode2
                            .Cells(1, startColumn) = ""
                            .Cells(1, startColumn + 1) = ""
                        Else
                            .Cells(i, startColumn + 2) = myNode2
                            i = i + 1
                        End If
                    
                    '�umainCategory�v�usubCategory�v�ucountStoredImages�v�^�O���̏ꍇ�A�����Ƀf�[�^�l�������o��
                    Else
                        .Cells(i, startColumn + 2) = myNode2
                        i = i + 1
                    End If
                    
                    '�ŏ���mainCategory���̂ݍ폜����(=2��ڈȍ~��mainCategory�����u�g�p�@����v�ɊY������)
                    If mainCategoryCount >= 1 And .Cells(i - 1, startColumn + 1) = "subFolderMode" And f_done = 0 Then
                        .Range(.Cells(startRow, startColumn), .Cells(1048576, startColumn + 3)).Clear
                        i = startRow
                        f_done = 1
                    End If
                    
                End Select
            Next
        Next
        
        '�\�[�g����
        maxRow = .Cells(1048576, startColumn).End(xlUp).Row
        
        '�Ώۍs���Ȃ��ꍇ�A�������I������
        If maxRow < startRow Then
            Exit Sub
        End If
        
        '�\�[�g�L�[: 1���
        .Sort.SortFields.Clear
        .Sort.SortFields.Add2 Key:=.Range(.Cells(startRow, startColumn), .Cells(maxRow, startColumn)), SortOn:=xlSortOnValues, Order:=xlAscending, DataOption:=xlSortNormal
        With .Sort
            .SetRange Range(Cells(startRow, startColumn), Cells(maxRow, startColumn + 3))
            .Header = xlGuess
            .MatchCase = False
            .Orientation = xlTopToBottom
            .SortMethod = xlPinYin
            .Apply
        End With
        
        '�usubCategory�v�^�O���ɁuimageFile�v�^�O���Ȃ��ꍇ�́A�ʐ^��񂪋�́uimageFile�v�s��ǉ�����
        For i = startRow To maxRow * 2
            
            '1��ڃf�[�^���󗓂̏ꍇ�A�������I������
            If .Cells(i, startColumn) = "" Then
                Exit For
            End If
            
            '�ʐ^������\���ucountStoredImages�v�f�[�^��0(=�ʐ^��񂪋�)�̏ꍇ�̂ݏ�������
            If .Cells(i, startColumn + 1) = "countStoredImages" And .Cells(i, startColumn + 2) = 0 Then
                
                '1�s�}��
                .Range(.Cells(i + 1, startColumn), .Cells(i + 1, startColumn + 3)).Insert Shift:=xlDown, CopyOrigin:=xlFormatFromLeftOrAbove
                .Cells(i + 1, startColumn) = .Cells(i, startColumn) + 1 '1��ڏ��Z�b�g
                .Cells(i + 1, startColumn + 1) = "imageFile"            '2��ڏ��Z�b�g(3,4��ڂ͋�)
            End If
            
        Next i

        '�\�[�g����(2���)
        maxRow = .Cells(1048576, startColumn).End(xlUp).Row
        
        '�\�[�g�L�[: 1���
        .Sort.SortFields.Clear
        .Sort.SortFields.Add2 Key:=.Range(.Cells(startRow, startColumn), .Cells(maxRow, startColumn)), SortOn:=xlSortOnValues, Order:=xlAscending, DataOption:=xlSortNormal
        With .Sort
            .SetRange Range(Cells(startRow, startColumn), Cells(maxRow, startColumn + 3))
            .Header = xlGuess
            .MatchCase = False
            .Orientation = xlTopToBottom
            .SortMethod = xlPinYin
            .Apply
        End With
    
    End With

End Sub
Sub unzipFileMaster()
    '**********************************
    '   ZIP-Master�f�[�^�𓀏���
    '
    '   Created by: Takashi Kawamoto
    '   Created on: 2023/9/6
    '**********************************
    
    Dim plistPath
    
    'PLIST-Master�f�[�^�p�X�擾
    plistPath = ThisWorkbook.Sheets("wk_Eno").Cells(1, 3)
    
    'ZIP�t�@�C���𓀏���
    Call unzipFile(plistPath)
    
End Sub
Sub unzipFileUpdated()
    '**********************************
    '   ZIP-�����f�[�^�𓀏���
    '
    '   Created by: Takashi Kawamoto
    '   Created on: 2023/9/6
    '**********************************
    
    Dim plistPath
    
    'PLIST-�����f�[�^�p�X�擾
    plistPath = ThisWorkbook.Sheets("wk_Eno").Cells(1, 7)
    
    'ZIP�t�@�C���𓀏���
    Call unzipFile(plistPath)
    
End Sub
Sub unzipFile(plistPath)
    '**********************************
    '   ZIP�t�@�C���𓀏���
    '
    '   Created by: Takashi Kawamoto
    '   Created on: 2023/9/6
    '**********************************
    
    Dim zipFilePath
    Dim psCommand
    Dim WSH As Object
    Dim result
    Dim posFld
    Dim toFolderPath
    
    '�u�@��ԍ�wk�V�[�g�v
    With ThisWorkbook.Sheets("wk_Eno")
    
        '��ZIP�t�@�C���p�X�擾
        zipFilePath = Replace(plistPath, "&img.plist", ".zip")
        
        '�t�@�C�����݃`�F�b�N
        If Dir(zipFilePath) = "" Then
            MsgBox (zipFilePath & " doesn't exist")
            Exit Sub
        End If
        
        '�𓀐�t�H���_�p�X�擾
        posFld = InStrRev(plistPath, "\")
        toFolderPath = Mid(plistPath, 1, posFld - 1)
        
        'ZIP�t�@�C���𓀏���
        Set WSH = CreateObject("WScript.Shell")
        
        '�t�@�C���p�X�Ɋ܂܂����ꕶ�����G�X�P�[�v����
        zipFilePath = Replace(zipFilePath, " ", "' '")
        zipFilePath = Replace(zipFilePath, "(", "'('")
        zipFilePath = Replace(zipFilePath, ")", "')'")
        zipFilePath = Replace(zipFilePath, "''", "")
        toFolderPath = Replace(toFolderPath, " ", "' '")
        toFolderPath = Replace(toFolderPath, "(", "'('")
        toFolderPath = Replace(toFolderPath, ")", "')'")
        toFolderPath = Replace(toFolderPath, "''", "")
        
        'ZIP�t�@�C���𓀃R�}���h�����s
        psCommand = "powershell -NoProfile -ExecutionPolicy Unrestricted Expand-Archive -Path """ & zipFilePath & """ -DestinationPath """ & toFolderPath & """ -Force"
        result = WSH.Run(psCommand, WindowStyle:=0, WaitOnReturn:=True)
    End With
    
    '�I������
    Set WSH = Nothing

End Sub
Sub comparePlist()
    '*************************************
    '   PLIST-Master-�����f�[�^��r����
    '
    '   Created by: Takashi Kawamoto
    '   Created on: 2023/9/6
    '*************************************
    
    Dim startRow
    Dim maxRow, maxRow1, maxRow2, maxRow3
    Dim key1, key2
    Dim cnt_main, cnt_sub1, cnt_sub2
    Dim f_inconsistent
    Dim i, j
    Dim strMainCategory
    Dim matchRow
    Dim fromRow1, toRow1, fromRow2, toRow2
    Dim cntRow1, cntRow2
    
    '��������
    startRow = 20
    cnt_main = 0
    cnt_sub1 = 0
    cnt_sub2 = 0
    f_inconsistent = 0

    '�u�@��ԍ�wk�V�[�g�v
    With ThisWorkbook.Sheets("wk_Eno")
    
        maxRow1 = .Cells(1048576, 1).End(xlUp).Row  'Master�f�[�^�ŏI�s�ԍ�
        maxRow2 = .Cells(1048576, 5).End(xlUp).Row  '�����f�[�^�ŏI�s�ԍ�
        If maxRow2 > maxRow1 Then
            maxRow = maxRow2
        Else
            maxRow = maxRow1
        End If
        
        '�J�n�s�ԍ�����ŏI�s�ԍ�(=Master�������f�[�^�̂ǂ��炩�s�����������̍ŏI�s�ԍ�)�܂ŏ������J��Ԃ�
        For i = startRow To maxRow
        
            key1 = .Cells(i, 3) 'Master�f�[�^�L�[���
            key2 = .Cells(i, 7) '�����f�[�^�L�[���
            
            '***************
            '�}�b�`���O����
            '***************
            
            '�L�[��񂪈�v�����珈������
            If key1 = key2 Then
            
                .Cells(i, 3).Font.Color = RGB(0, 0, 255)    '�F
                .Cells(i, 7).Font.Color = RGB(0, 0, 255)    '�F
                
            '�L�[��񂪃u���[�N�����珈������
            Else
            
                '���f�[�^��r�s��2��ڕ����������uimageFile�v(=�ʐ^���)�ł������ꍇ
                If .Cells(i, 2) = "imageFile" And .Cells(i, 6) = "imageFile" Then
                
                    '�ʐ^���ɕύX���������ꍇ�A�Y������usubCategory�v�ucountStoredImages�v�uimageFile�v��3�s���Z�b�g�ŕ����F��ύX����
                    '�ʐ^���ɕύX���������usubCategory�v�s��4���(�����f�[�^���̂�)�Ɏ��ʃ}�[�J�u*�v��ǉ�����
                    .Cells(i - 2, 3).Font.Color = RGB(0, 255, 0)    '�ΐF(Master�f�[�^��)
                    .Cells(i - 1, 3).Font.Color = RGB(0, 255, 0)    '�ΐF(Master�f�[�^��)
                    .Cells(i, 3).Font.Color = RGB(0, 255, 0)        '�ΐF(Master�f�[�^��)
                    .Cells(i - 2, 7).Font.Color = RGB(255, 0, 0)    '�ԐF(�����f�[�^��)
                    .Cells(i - 1, 7).Font.Color = RGB(255, 0, 0)    '�ԐF(�����f�[�^��)
                    .Cells(i, 7).Font.Color = RGB(255, 0, 0)        '�ԐF(�����f�[�^��)
                    .Cells(i - 2, 8) = .Cells(i - 2, 8) & "*"
                    
                '���f�[�^��r�s��2��ڕ����������usubCategory�v(=�T�u�J�e�S����)�ł������ꍇ
                ElseIf .Cells(i, 2) = "subCategory" And .Cells(i, 6) = "subCategory" Then
                
                    '�T�u�J�e�S�����ɕύX���������ꍇ�A�Y������usubCategory�v�s�̕����F��ύX����
                    '�T�u�J�e�S�����ɕύX���������s��4���(�����f�[�^���̂�)�Ɏ��ʃ}�[�J�u#�v��ǉ�����
                    .Cells(i, 3).Font.Color = RGB(0, 255, 0)        '�ΐF(Master��)
                    .Cells(i, 7).Font.Color = RGB(255, 0, 0)        '�ԐF(�X�V�t�@�C����)
                    .Cells(i, 8) = .Cells(i, 8) & "#"
                End If
                
            End If
        Next i
    End With

    '�u�g�p�@��wk�V�[�g�v
    With ThisWorkbook.Sheets("wk_cb")
    
        '�ꎞ�G���A�N���A
        .Range(.Columns(9), .Columns(12)).Clear
        
        '�V�[�g�S�̂̕����F���u�����v�ɍĐݒ�
        .Cells.Font.ColorIndex = xlAutomatic
        
        maxRow1 = .Cells(1048576, 2).End(xlUp).Row  'Master�f�[�^�ŏI�s�ԍ�
        If maxRow1 < startRow Then
            maxRow1 = startRow - 1  'Master�f�[�^�Ȃ��̏ꍇ�A�ŏI�s�ԍ��ɉ��̔ԍ����Z�b�g
        End If
        maxRow3 = maxRow1   '�ꎞ�G���A�ŏI�s�ԍ�(=Master�f�[�^�ŏI�s�ԍ�)������
        
        maxRow2 = .Cells(1048576, 6).End(xlUp).Row  '�����f�[�^�ŏI�s�ԍ�
        If maxRow2 < startRow Then
            maxRow2 = startRow - 1  'Master�f�[�^�Ȃ��̏ꍇ�A�ŏI�s�ԍ��ɉ��̔ԍ����Z�b�g
        End If
        
        '�����l
        cnt_main = 0
        
        '�J�n�s�ԍ����玝���f�[�^�̍ŏI�s�ԍ��܂ŏ������J��Ԃ�
        '�˔�r������Master�f�[�^�̍s���ɂ�����炸�A�����f�[�^�̑S�s������r�`�F�b�N�ł���΂悢�Ƃ����l����
        For i = startRow To maxRow2
        
            '�����f�[�^�̍s��񂪁umainCategory�v�̏ꍇ�A�u���C���J�e�S�����v���擾
            If .Cells(i, 8) = "@" Then
                strMainCategory = .Cells(i, 7)
                cnt_main = cnt_main + 1         '�umainCategory�v���J�E���g�A�b�v
                
                'Master�f�[�^�ɁA�����f�[�^�ƈ�v���郁�C���J�e�S����(=�`�F�b�N���ږ�)���Ȃ��ꍇ�A
                'Master�f�[�^���ɁA�����f�[�^�̓����C���J�e�S�����(=�g�p�@����=�`�F�b�N�{�b�N�X���)���ۂ��ƃR�s�[����
                matchRow = 0
                On Error Resume Next
                matchRow = WorksheetFunction.Match(strMainCategory, ThisWorkbook.Sheets("wk_cb").Columns(3), 0) 'Master�f�[�^3��ڂ��玝�o�f�[�^�́u���C���J�e�S�����v�ƈ�v����s�ԍ��������E�擾
                On Error GoTo 0
                
                '�}�b�`���O���ʁˊY���Ȃ��̏ꍇ
                If matchRow = 0 Then
                
                    '�R�s�[�������f�[�^�G���A
                    fromRow2 = i                                        '�R�s�[���J�n�s�擾
                    toRow2 = .Cells(fromRow2, 8).End(xlDown).Row - 1    '�R�s�[���I���s�擾
                    If toRow2 > maxRow2 Then
                        toRow2 = maxRow2
                    End If
                    cntRow2 = toRow2 - fromRow2 + 1 '�R�s�[�s���擾
                    
                    '�R�s�[�������f�[�^�G���A���ꎞ�G���A�ɃR�s�[
                    .Range(.Cells(fromRow2, 6), .Cells(toRow2, 8)).Copy Destination:=.Cells(maxRow3 + 1, 10)    '�R�s�[��ˈꎞ�G���A�̖���
                    With .Range(.Cells(maxRow3 + 1, 10), .Cells(maxRow3 + cntRow2, 12))
                        .Font.Color = RGB(255, 0, 0)    '�R�s�[��G���A�ːԐF
                    End With
                    
                    '�ꎞ�G���A�ŏI�s�ԍ���Master�f�[�^�Ɛ����������悤�ɒ�������
                    maxRow3 = .Cells(1048576, 10).End(xlUp).Row  '�ꎞ�G���A�ŏI�s�ԍ��X�V
                    If maxRow3 < maxRow1 Then
                        maxRow3 = maxRow1   '�ꎞ�G���A�ŏI�s�ԍ�(=Master�f�[�^�ŏI�s�ԍ�)�X�V
                    End If
                    
                '�}�b�`���O���ʁˊY������̏ꍇ
                Else
                
                    '*************************************************
                    'Master�f�[�^�ƍX�V�f�[�^�̈�v�G���A�s���`�F�b�N
                    '*************************************************
                    
                    'Master�f�[�^�s���擾
                    fromRow1 = matchRow
                    toRow1 = .Cells(fromRow1, 4).End(xlDown).Row - 1
                    If toRow1 > maxRow1 Then
                        toRow1 = maxRow1
                    End If
                    cntRow1 = toRow1 - fromRow1 + 1
                        
                    '�����f�[�^�s���擾
                    fromRow2 = i
                    toRow2 = .Cells(fromRow2, 8).End(xlDown).Row - 1
                    If toRow2 > maxRow2 Then
                        toRow2 = maxRow2
                    End If
                    cntRow2 = toRow2 - fromRow2 + 1
                    
                    '�s������v�����ꍇ
                    If cntRow1 = cntRow2 Then
                    
                        '�R�s�[�������f�[�^�G���A���ꎞ�G���A�ɃR�s�[
                        .Range(.Cells(fromRow2, 6), .Cells(toRow2, 8)).Copy Destination:=.Cells(matchRow, 10)   '�R�s�[��ˈꎞ�G���A�́u�}�b�`���O��v�s�ԍ��v
                        
                        '�ꎞ�G���A�ŏI�s�ԍ���Master�f�[�^�Ɛ����������悤�ɒ�������
                        maxRow3 = .Cells(1048576, 10).End(xlUp).Row  '�ꎞ�G���A�ŏI�s�ԍ��X�V
                        If maxRow3 < maxRow1 Then
                            maxRow3 = maxRow1   '�ꎞ�G���A�ŏI�s�ԍ�(=Master�f�[�^�ŏI�s�ԍ�)�X�V
                        End If
                        
                    '�s������v���Ȃ������ꍇ
                    Else
                    
                        'Master�f�[�^�̕��������f�[�^�����s�������Ȃ��ꍇ (���ꎎ�����ڂ̎g�p�@�킪�ǉ����ꂽ�ꍇ��z��)
                        If cntRow1 < cntRow2 Then
                        
                            'Master�f�[�^�G���A�ɋ󔒍s��ǉ����āA�����f�[�^�G���A�ƑΉ�����s�ԍ�����v������
                            .Range(.Cells(toRow1 + 1, 1), .Cells(toRow1 + 1, 4)).Insert Shift:=xlDown, CopyOrigin:=xlFormatFromLeftOrAbove
                            .Range(.Cells(toRow1 + 1, 1), .Cells(toRow1 + 1, 4)).Copy
                            .Range(.Cells(toRow1 + 1, 1), .Cells(toRow1 + (cntRow2 - cntRow1) - 1, 4)).Insert Shift:=xlDown, CopyOrigin:=xlFormatFromLeftOrAbove
                            maxRow1 = .Cells(1048576, 2).End(xlUp).Row  'Master�f�[�^�ŏI�s�ԍ��X�V
                            
                            '�ꎞ�G���A�ɂ�Master�f�[�^�G���A�Ɠ����󔒍s��ǉ����āAMaster�f�[�^�G���A�ƑΉ�����s�ԍ�����v������
                            .Range(.Cells(toRow1 + 1, 9), .Cells(toRow1 + 1, 12)).Insert Shift:=xlDown, CopyOrigin:=xlFormatFromLeftOrAbove
                            .Range(.Cells(toRow1 + 1, 9), .Cells(toRow1 + 1, 12)).Copy
                            .Range(.Cells(toRow1 + 1, 9), .Cells(toRow1 + (cntRow2 - cntRow1) - 1, 12)).Insert Shift:=xlDown, CopyOrigin:=xlFormatFromLeftOrAbove
                            maxRow3 = .Cells(1048576, 10).End(xlUp).Row  '�ꎞ�G���A�ŏI�s�ԍ��X�V
                            
                            '�R�s�[�������f�[�^�G���A���ꎞ�G���A�ɃR�s�[
                            .Range(.Cells(fromRow2, 6), .Cells(toRow2, 8)).Copy Destination:=.Cells(fromRow1, 10)   '�R�s�[��ˈꎞ�G���A�́uMaster�f�[�^��v�G���A�J�n�s�ԍ�=�}�b�`���O��v�s�ԍ��v
                            With .Range(.Cells(maxRow3 + 1, 10), .Cells(maxRow3 + cntRow2, 12))
                                .Font.Color = RGB(255, 0, 0)    '�R�s�[��G���A�ːԐF
                            End With
                            
                            '�ꎞ�G���A�ŏI�s�ԍ���Master�f�[�^�Ɛ����������悤�ɒ�������
                            maxRow3 = .Cells(1048576, 10).End(xlUp).Row  '�ꎞ�G���A�ŏI�s�ԍ��X�V
                            If maxRow3 < maxRow1 Then
                                maxRow3 = maxRow1   '�ꎞ�G���A�ŏI�s�ԍ�(=Master�f�[�^�ŏI�s�ԍ�)�X�V
                            End If
                                                       
                        'Master�f�[�^�̕��������f�[�^�����s���������ꍇ (iOS�A�v�����ŕs�����f�[�^���쐬���ꂽ�ꍇ��z��)
                        ElseIf cntRow1 > cntRow2 Then
                        
                            '�R�s�[�������f�[�^�G���A���ꎞ�G���A�ɃR�s�[
                            .Range(.Cells(fromRow2, 6), .Cells(toRow2, 8)).Copy Destination:=.Cells(fromRow1, 10)   '�R�s�[��ˈꎞ�G���A�́uMaster�f�[�^��v�G���A�J�n�s�ԍ�=�}�b�`���O��v�s�ԍ��v
                            
                            '�ꎞ�G���A�ŏI�s�ԍ���Master�f�[�^�Ɛ����������悤�ɒ�������
                            maxRow3 = .Cells(1048576, 10).End(xlUp).Row  '�ꎞ�G���A�ŏI�s�ԍ��X�V
                            If maxRow3 < maxRow1 Then
                                maxRow3 = maxRow1  '�ꎞ�G���A�ŏI�s�ԍ�(=Master�f�[�^�ŏI�s�ԍ�)�X�V
                            End If
                            
                        End If
                    End If
                End If
            End If
        Next i
        
        '�ꎞ�G���A��Ǝ����f�[�^������ւ�
        .Range(.Columns(9), .Columns(12)).Cut
        .Columns(5).Insert Shift:=xlToRight
        
        '�}�b�`���O����
        For j = startRow To maxRow1
        
            '�����f�[�^�����f�[�^�Ȃ��̏ꍇ�A�}�b�`���O�����s�v
            If .Cells(j, 6) = "" Then
                .Range(.Cells(j, 1), .Cells(j, 4)).Font.Color = RGB(0, 255, 0)       '�ΐF(Master�f�[�^��)
                
            'Master�f�[�^�����f�[�^�Ȃ��̏ꍇ�A�}�b�`���O�����s�v
            ElseIf .Cells(j, 2) = "" Then
                .Range(.Cells(j, 5), .Cells(j, 8)).Font.Color = RGB(255, 0, 0)       '�ԐF(�����f�[�^��)
                
            'Master�f�[�^�Ǝ����f�[�^�������Ƃ�����ꍇ�A�}�b�`���O�������s��
            Else
                key1 = .Cells(j, 3) 'Master�f�[�^�L�[���
                key2 = .Cells(j, 7) '�����f�[�^�L�[���
    
                '***************
                '�}�b�`���O����
                '***************
                
                '�L�[��񂪈�v�����珈������
                If key1 = key2 Then
                
                    .Cells(j, 3).Font.Color = RGB(0, 0, 255)    '�F
                    .Cells(j, 7).Font.Color = RGB(0, 0, 255)    '�F
                
                '�L�[��񂪃u���[�N�����珈������
                Else
                    
                    '���f�[�^��r�s��2��ڕ����������uimageFile�v(=�ʐ^���)�ł������ꍇ
                    If .Cells(j, 2) = "imageFile" And .Cells(j, 6) = "imageFile" Then
                    
                        '�ʐ^���ɕύX���������ꍇ�A�Y������usubCategory�v�ucountStoredImages�v�uimageFile�v��3�s���Z�b�g�ŕ����F��ύX����
                        '�ʐ^���ɕύX���������usubCategory�v�s��4���(�����f�[�^���̂�)�Ɏ��ʃ}�[�J�u*�v��ǉ�����
                        .Cells(j - 2, 3).Font.Color = RGB(0, 255, 0)    '�ΐF(Master�f�[�^��)
                        .Cells(j - 1, 3).Font.Color = RGB(0, 255, 0)    '�ΐF(Master�f�[�^��)
                        .Cells(j, 3).Font.Color = RGB(0, 255, 0)        '�ΐF(Master�f�[�^��)
                        .Cells(j - 2, 7).Font.Color = RGB(255, 0, 0)    '�ԐF(�����f�[�^��)
                        .Cells(j - 1, 7).Font.Color = RGB(255, 0, 0)    '�ԐF(�����f�[�^��)
                        .Cells(j, 7).Font.Color = RGB(255, 0, 0)        '�ԐF(�����f�[�^��)
                        .Cells(j - 2, 8) = .Cells(j - 2, 8) & "*"
                        
                    '���f�[�^��r�s��2��ڕ����������usubCategory�v(=�T�u�J�e�S����)�ł������ꍇ
                    ElseIf .Cells(j, 2) = "subCategory" And .Cells(j, 6) = "subCategory" Then
                    
                        '�T�u�J�e�S�����ɕύX���������ꍇ�A�Y������usubCategory�v�s�̕����F��ύX����
                        '�T�u�J�e�S�����ɕύX���������s��4���(�����f�[�^���̂�)�Ɏ��ʃ}�[�J�u#�v��ǉ�����
                        .Cells(j, 3).Font.Color = RGB(0, 255, 0)        '�ΐF(Master�f�[�^��)
                        .Cells(j, 7).Font.Color = RGB(255, 0, 0)        '�ԐF(�����f�[�^��)
                        .Cells(j, 8) = .Cells(j, 8) & "#"
                    End If
                    
                End If
            End If
        Next j
    End With

End Sub
Sub mergePlist()
    '**********************************
    '   PLIST���}�[�W����
    '
    '   Created by: Takashi Kawamoto
    '   Created on: 2023/9/6
    '**********************************
    
    Dim startRow2
    Dim maxRow1, maxRow2, maxRow3
    Dim lastSubRow
    Dim i
    Dim str1
    Dim int1
    Dim strMainCategory
    
    '�u�@��ԍ�wk�V�[�g�v
    With ThisWorkbook.Sheets("wk_Eno")
    
        '�A���}�b�`�f�[�^������ꍇ
        If WorksheetFunction.CountA(.Columns(8)) > 0 Then
        
            startRow2 = .Cells(19, 8).End(xlDown).Row   '�����f�[�^�A���}�b�`�擪�usubCategory�v�s�ԍ�
            maxRow2 = .Cells(1048576, 8).End(xlUp).Row  '�����f�[�^�A���}�b�`�ŏI�usubCategory�v�s�ԍ�
            
            '�����f�[�^�A���}�b�`�G���A�̐擪�s�ԍ�����ŏI�s�ԍ��܂ŏ������J��Ԃ�
            For i = startRow2 To maxRow2
            
                '�A���}�b�`���ʃ}�[�N�ʂɏ�������
                Select Case .Cells(i, 8)
                
                '�u�ʐ^���v�A���}�b�`
                Case "*"
                
                    'Master�f�[�^���́u�ʐ^���v���Ȃ�(��)�ꍇ�̂݁AMaster�f�[�^���Ɏ����f�[�^���(�ʐ^�������ʐ^��)���R�s�[����
                    If .Cells(i + 2, 3) = "" Then
                        .Cells(i + 1, 3) = .Cells(i + 1, 7) '�ʐ^����
                        .Cells(i + 2, 3) = .Cells(i + 2, 7) '�ʐ^��(������)
                        .Cells(i + 1, 3).Font.Color = RGB(255, 0, 0)    '�ԐF(�X�V��)
                        .Cells(i + 2, 3).Font.Color = RGB(255, 0, 0)    '�ԐF(�X�V��)
                        
                    'Master�f�[�^���́u�ʐ^���v������ꍇ�A���o�f�[�^���ɂ��㏑���͍s�킸�A�m�F���b�Z�[�W��\������݂̂Ƃ���
                    Else
                    
                        '�����f�[�^���́u�ʐ^���v�̗L���ɂ��A�Ή�����m�F���b�Z�[�W��\������B
                        If .Cells(i + 2, 7) = "" Then
                            MsgBox ("SubCategory: " & .Cells(i, 7) & " �˃}�X�^�[�̎ʐ^���폜����ꍇ�͎��ƂŃ}�X�^�[�����㏑�����Ă�������")
                        Else
                            MsgBox ("SubCategory: " & .Cells(i, 7) & " �˃}�X�^�[�̎ʐ^��ύX����ꍇ�͎��ƂŃ}�X�^�[�����㏑�����Ă�������")
                        End If
                        
                    End If
                    
                '�u�T�u�J�e�S�����v�A���}�b�`
                Case "#"
                
                    '���o�f�[�^���ɂ��Master�f�[�^���̏㏑���͍s�킸�A�m�F���b�Z�[�W��\������݂̂Ƃ���
                    MsgBox ("SubCategory: " & .Cells(i, 7) & " �˃}�X�^�[�̃T�u�J�e�S������ύX����ꍇ�͎��ƂŃ}�X�^�[�����㏑�����Ă�������")
                    
                '�u�ʐ^���v���u�T�u�J�e�S�����v�A���}�b�`
                Case "#*"
                    
                    '���o�f�[�^���ɂ��Master�f�[�^���̏㏑���͍s�킸�A�m�F���b�Z�[�W��\������݂̂Ƃ���
                    MsgBox ("SubCategory: " & .Cells(i, 7) & " �˃}�X�^�[�̃T�u�J�e�S�����^�ʐ^��ύX����ꍇ�͎��ƂŃ}�X�^�[�����㏑�����Ă�������")
                    
                End Select
            Next i
                       
            '��d�����h���l��
            .Columns(8).Clear
            
        End If
    End With
    
    '�u�g�p�@��wk�V�[�g�v
    With ThisWorkbook.Sheets("wk_cb")
        
        '�g�p�@��(=�`�F�b�N�{�b�N�X)�f�[�^������ꍇ�̂ݏ�������
        If WorksheetFunction.CountA(.Columns(8)) > 0 Then
        
            startRow2 = 20   '�����f�[�^�擪�s�ԍ�
            maxRow2 = .Cells(1048576, 6).End(xlUp).Row  '�����f�[�^�ŏI�s�ԍ�
            
            '�����f�[�^�̐擪�s�ԍ�����ŏI�s�ԍ��܂ŏ������J��Ԃ�
            For i = startRow2 To maxRow2
            
                '�A���}�b�`���ʃ}�[�N�ʂɏ�������
                Select Case .Cells(i, 8)
                
                '�u���C���J�e�S�����v�A���}�b�`
                Case "@"
                
                    strMainCategory = .Cells(i, 7)  '���C���J�e�S�����擾
                                        
                    'Master�f�[�^���́u���C���J�e�S�����v���Ȃ�(��)�ꍇ�̂݁A�����f�[�^�����ۂ��ƃR�s�[����
                    If .Cells(i, 2) = "" Then
                        .Cells(i, 2) = .Cells(i, 6)
                        .Cells(i, 3) = .Cells(i, 7)
                        .Range(.Cells(i, 2), .Cells(i, 3)).Font.Color = RGB(255, 0, 0)  '�ԐF(�X�V��)
                    End If
                    
                '�A���}�b�`���ʃ}�[�N�Ȃ�(=��)
                Case ""
                
                    'Master�f�[�^���ɏ�񂪂Ȃ�(��)�ꍇ�̂݁A�����f�[�^�����ۂ��ƃR�s�[����
                    If .Cells(i, 2) = "" Then
                        .Cells(i, 2) = .Cells(i, 6)
                        .Cells(i, 3) = .Cells(i, 7)
                        .Range(.Cells(i, 2), .Cells(i, 3)).Font.Color = RGB(255, 0, 0)  '�ԐF(�X�V��)
                    End If
                    
                '�u�ʐ^���v�A���}�b�`
                Case "*"
                    
                    'Master�f�[�^���́u�ʐ^���v���Ȃ�(��)�ꍇ�̂݁AMaster�f�[�^���Ɏ����f�[�^���(�ʐ^�������ʐ^��)���R�s�[����
                   If .Cells(i + 2, 3) = "" Then
                        .Cells(i + 1, 3) = .Cells(i + 1, 7)
                        .Cells(i + 2, 3) = .Cells(i + 2, 7)
                        .Cells(i + 1, 3).Font.Color = RGB(255, 0, 0)    '�ԐF(�X�V��)
                        .Cells(i + 2, 3).Font.Color = RGB(255, 0, 0)    '�ԐF(�X�V��)
                        
                    'Master�f�[�^���́u�ʐ^���v������ꍇ�A���o�f�[�^���ɂ��㏑���͍s�킸�A�m�F���b�Z�[�W��\������݂̂Ƃ���
                    Else
                    
                        '�����f�[�^���́u�ʐ^���v�̗L���ɂ��A�Ή�����m�F���b�Z�[�W��\������B
                        Select Case .Cells(i + 2, 7)
                        Case ""
                            MsgBox ("MainCategory:�u" & strMainCategory & "�vSubCategory:�u" & .Cells(i, 7) & "�v" & Chr(10) & "�˃}�X�^�[�̎ʐ^���폜����ꍇ�͎��ƂŃ}�X�^�[�����㏑�����Ă�������")
                        Case Else
                            MsgBox ("MainCategory:�u" & strMainCategory & "�vSubCategory:�u" & .Cells(i, 7) & "�v" & Chr(10) & "�˃}�X�^�[�̎ʐ^��ύX����ꍇ�͎��ƂŃ}�X�^�[�����㏑�����Ă�������")
                        End Select
                        
                    End If
                    
                '�u�T�u�J�e�S�����v�A���}�b�`
                Case "#"
                
                    Select Case .Cells(i, 3) & .Cells(i, 7)
                    
                    '�g�p�@������u�g�p�Ȃ��v�ˁu�g�p����v�ɕύX����ꍇ�@�ˍX�V����
                    Case .Cells(i, 3) & "*" & .Cells(i, 3)
                        .Cells(i, 3) = .Cells(i, 7)
                        .Cells(i, 3).Font.Color = RGB(255, 0, 0)    '�ԐF(�X�V��)
                    
                     '�g�p�@������u�g�p����v�ˁu�g�p�Ȃ��v�ɕύX����ꍇ�@�ˍX�V�Ȃ��Ƃ���(���R�F��x�u�g�p����v�ɂȂ������̂��u�g�p�Ȃ��v�ɕύX����邱�Ƃ͑z�肵�Ȃ���)
                    Case "*" & .Cells(i, 7) & .Cells(i, 7)
                    
                        '�X�V�Ȃ�(�m�F���b�Z�[�W�̂�)
                        MsgBox ("MainCategory:�u" & strMainCategory & "�vSubCategory:�u" & .Cells(i, 7) & "�v" & Chr(10) & "�ˋ@��̎g�p�󋵂��u�g�p�Ȃ��v�ɕύX����ꍇ�͎��ƂŃ}�X�^�[�����㏑�����Ă�������")
                    
                    Case Else
                    
                        '�X�V�Ȃ�(�m�F���b�Z�[�W�̂�)
                        MsgBox ("MainCategory:�u" & strMainCategory & "�vSubCategory:�u" & .Cells(i, 7) & "�v" & Chr(10) & "�˃}�X�^�[�̃T�u�J�e�S������ύX����ꍇ�͎��ƂŃ}�X�^�[�����㏑�����Ă�������")
                        
                    End Select
                    
                '�u�ʐ^���v���u�T�u�J�e�S�����v�A���}�b�`
                Case "#*"
                
                    '���o�f�[�^���ɂ��Master�f�[�^���̏㏑���͍s�킸�A�m�F���b�Z�[�W��\������݂̂Ƃ���
                    MsgBox ("MainCategory:�u" & strMainCategory & "�vSubCategory:�u" & .Cells(i, 7) & "�v" & Chr(10) & "�˃}�X�^�[�̃T�u�J�e�S�����^�ʐ^��ύX����ꍇ�͎��ƂŃ}�X�^�[�����㏑�����Ă�������")
                
                End Select
            Next i
                       
            '��d�����h���l��
            .Columns(8).Clear
            
        End If
        
    End With
    
    '�I������
    MsgBox ("PLIST(��)�X�V���X�g�o�͍ς�")
End Sub
Sub applyPlistAndZip()
    '**********************************
    '   PLIST��ZIP�X�V���f����
    '
    '   Created by: Takashi Kawamoto
    '   Created on: 2023/9/6
    '**********************************
    
    'temp�t�H���_�L���`�F�b�N �˂Ȃ��ꍇ�A�������I������
    If Dir("c:\temp", vbDirectory) = "" Then
        MsgBox ("�uC:\temp�v�t�H���_���쐬��A�ēx���s���Ă�������")
        Exit Sub
    End If
    
    '�u�@��ԍ�wk�V�[�g�v
    With ThisWorkbook.Sheets("wk_Eno")
    
        'PLIST-Master�f�[�^�p�X��PLIST-�����f�[�^�p�X������̏ꍇ�͍X�V�����s�v�ׁ̈A�������I������
        If .Cells(1, 3) = .Cells(1, 7) Then
            MsgBox ("�����f�[�^��PLIST��Master�Ɠ���̈׍X�V�Ȃ�")
            Exit Sub
        End If
        
    End With
    
    'ZIP�t�@�C���}�[�W����
    Call mergeZip
    
    'PLIST�X�V���f����
    Call applyPlist
    
    '�����I��
    MsgBox ("PLIST & ZIP�t�@�C���X�V�ς�")
End Sub
Sub mergeZip()
    '**********************************
    '   ZIP�t�@�C���}�[�W����
    '
    '   Created by: Takashi Kawamoto
    '   Created on: 2023/9/6
    '**********************************
    
    Dim masterDir
    Dim masterDirFile
    Dim updatedDir
    Dim updatedDirFile
    Dim updatedDirFilename
    Dim zipSrcFolder
    Dim toFolder
    
    'Master�f�[�^(�ʐ^)�t�H���_
    masterDir = ThisWorkbook.Path & "\Master\SampleList"
    
    'Master�f�[�^�t�H���_���Ȃ��ꍇ�͐V�K�쐬����
    If Dir(masterDir, vbDirectory) = "" Then
        MkDir masterDir
    End If
    
    '�u�@��ԍ�wk�V�[�g�v
    With ThisWorkbook.Sheets("wk_Eno")
    
        '�����f�[�^(�ʐ^)�t�H���_
        updatedDir = Replace(.Cells(1, 7), "&img.plist", "")
        
        '�����f�[�^�t�H���_���̐擪�摜�t�@�C����(=�ʐ^��)���擾����
        updatedDirFilename = Dir(updatedDir & "\*.jpg")
        
        '�ړ����ƈړ���̃t�H���_������̏ꍇ�͏������Ȃ�(=�����I��)
        If masterDir = updatedDir Then
            Exit Sub
        End If
        
        '�����f�[�^�t�H���_���̉摜�t�@�C�����ƂɌJ��Ԃ�
        Do While updatedDirFilename <> ""
            updatedDirFile = updatedDir & "\" & updatedDirFilename  '�����f�[�^�摜�t�@�C���p�X(�ړ���)
            masterDirFile = masterDir & "\" & updatedDirFilename    'Master�f�[�^�摜�t�@�C���p�X(�ړ���)
            
            With CreateObject("Scripting.FileSystemObject")
            
                '�ړ���ɓ����̉摜�t�@�C�������ɑ��݂���ꍇ�́A�ړ����̉摜�t�@�C�����폜����(�u�������͂��Ȃ�)
                If .FileExists(masterDirFile) Then
                    Kill updatedDirFile
                    
                '�ړ���ɓ����̉摜�t�@�C�������݂��Ȃ��ꍇ�́A�ړ����̉摜�t�@�C�����ړ���Ɉړ�����
                Else
                    Name updatedDirFile As masterDirFile
                    
                End If
            End With
            
            updatedDirFilename = Dir()  '�����f�[�^�t�H���_���̎��̉摜�t�@�C�������擾����
            
        Loop
    End With
    
    '�ēx�A�����f�[�^�t�H���_���̐擪�摜�t�@�C�������擾����
    updatedDirFilename = Dir(updatedDir & "*.jpg")
    
    '�����f�[�^�t�H���_����(��ɂȂ��Ă���͂��Ȃ̂�)��̏ꍇ�́A�����f�[�^�t�H���_���폜����
    If updatedDirFilename = "" Then
        With CreateObject("Scripting.FileSystemObject")
            If Dir(updatedDir, vbDirectory) <> "" Then
                .DeleteFolder updatedDir
            End If
        End With
    End If
    
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
Public Sub ZipFileOrFolder2(ByVal SrcPath As Variant)
    '**********************************
    '   ZIP���k����
    '
    '   Created by: Takashi Kawamoto
    '   Created on: 2023/9/6
    '**********************************
    '   �t�@�C���E�t�H���_��ZIP�`���ň��k
    '   SrcPath�F���t�@�C���E�t�H���_
    
    Dim DestFilePath
    Dim psCommand
    Dim WSH As Object
    Dim result
    
    '�o�͐�ZIP�t�@�C���p�X
    DestFilePath = SrcPath & ".zip"
    
    'ZIP���k����
    Set WSH = CreateObject("WScript.Shell")
    
    '�t�@�C���p�X�Ɋ܂܂����ꕶ�����G�X�P�[�v����
    SrcPath = Replace(SrcPath, " ", "' '")
    SrcPath = Replace(SrcPath, "(", "'('")
    SrcPath = Replace(SrcPath, ")", "')'")
    SrcPath = Replace(SrcPath, "''", "")
    DestFilePath = Replace(DestFilePath, " ", "' '")
    DestFilePath = Replace(DestFilePath, "(", "'('")
    DestFilePath = Replace(DestFilePath, ")", "')'")
    DestFilePath = Replace(DestFilePath, "''", "")
    
    'ZIP���k�R�}���h�����s
    psCommand = "powershell -NoProfile -ExecutionPolicy Unrestricted Compress-Archive -Path """ & SrcPath & """ -DestinationPath """ & DestFilePath & """ -Force"
    result = WSH.Run(psCommand, WindowStyle:=0, WaitOnReturn:=True)
    
    '�I������
    Set WSH = Nothing


End Sub
Public Sub ZipFileOrFolder(ByVal SrcPath As Variant, Optional ByVal DestFolderPath As Variant = "")
    '**********************************
    '   ZIP���k����
    '
    '   Created by: Takashi Kawamoto
    '   Created on: 2023/9/6
    '**********************************
    '   �t�@�C���E�t�H���_��ZIP�`���ň��k
    '   SrcPath�F���t�@�C���E�t�H���_
    '   DestFolderPath�F�o�͐�A�w�肵�Ȃ��ꍇ�͌��t�@�C���E�t�H���_�Ɠ����ꏊ
    
    Dim DestFilePath As Variant
   
    With CreateObject("Scripting.FileSystemObject")
    
        '�o�͐�ZIP�t�@�C���p�X
        DestFilePath = SrcPath & ".zip"
        
        '���ZIP�t�@�C�����쐬����
        With .CreateTextFile(DestFilePath, True)
            '.Write ChrW(&H50) & ChrW(&H4B) & ChrW(&H5) & ChrW(&H6) & String(18, ChrW(0))
            .Write "PK" & Chr(5) & Chr(6) & String(18, 0)
            .Close
        End With
        
    End With
   
    'ZIP���k���s
    With CreateObject("Shell.Application")
        With .Namespace(DestFilePath)
            .CopyHere SrcPath
            While .Items.Count < 1
                DoEvents
            Wend
        End With
    End With
    
End Sub
Sub applyPlist()
    '**********************************
    '   PLIST�X�V���f����
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
    Dim i, j, k        As Integer
    Dim tempFile
    Dim startRow, maxRow
    Dim arrMain(1000) As Variant
    Dim arrSFMode(1000) As Variant
    Dim cnt_main, cnt_sub, cnt_main1_sub
    Dim arr1(1000, 1000) As Variant
    Dim arr2(1000, 1000) As Variant
    Dim arr3(1000, 1000) As Variant
    Dim arr4 As Variant
    
    '�u�@��ԍ�wk�V�[�g�v�c�@��ԍ����
    With ThisWorkbook.Sheets("wk_Eno")
    
        tempFile = "c:\\temp\\temp.plist"   '�ꎞ�t�@�C��
        
        'PLIST-Master�f�[�^������PLIST�uSampleList.plist�v�̏ꍇ�A�{�X�V��́uSampleList&img.plist�v�Ƃ��ĕۑ�����邽��
        '�u&img.plist�v�t����PLIST-Master�f�[�^�t�@�C�����Ƀ��l�[������
        If InStr(.Cells(1, 3), "&img.plist") = 0 Then
            .Cells(1, 3) = ThisWorkbook.Path & "\Master\SampleList&img.plist"
        End If
        fileName = .Cells(1, 3)                     'PLIST-Master�f�[�^�t�@�C���p�X
                
        'XML�t�@�C���o�͏���
        Set xmlDoc = New MSXML2.DOMDocument60
        Set xmlPI = xmlDoc.appendChild(xmlDoc.createProcessingInstruction("xml", "version=""1.0"" encoding=""UTF-8"""))
        Set xmlPI = xmlDoc.appendChild(xmlDoc.createProcessingInstruction("DOCTYPE", ""))
        Set node(1) = xmlDoc.appendChild(xmlDoc.createNode(NODE_ELEMENT, "plist", ""))
        Set node(2) = node(1).appendChild(xmlDoc.createNode(NODE_ELEMENT, "array", ""))
        
        '�����l
        startRow = 20                               'Master�f�[�^�擪�s�ԍ�
        maxRow = .Cells(1048576, 2).End(xlUp).Row   'Master�f�[�^�ŏI�s�ԍ�
        cnt_main = 0                                'mainCategory�v�f��
        cnt_sub = 0                                 'subCategory�v�f��
        
        'Master�f�[�^�̐擪�s�ԍ�����ŏI�s�ԍ��܂ŏ������J��Ԃ�
        For i = startRow To maxRow
        
            '�umainCategory�v���擾
            If .Cells(i, 2) = "mainCategory" Then
                cnt_main = cnt_main + 1                 'mainCategory�v�f�J�E���g�A�b�v
                arrMain(cnt_main) = .Cells(i, 3)        'mainCategory���z��Z�b�g
                arrSFMode(cnt_main) = .Cells(i + 1, 3)  'subFolderMode���z��Z�b�g
            End If
            
            '����umainCategory�v�v�f���̂ݏ�������
            If cnt_main = 1 Then
            
                '�usubCategory�v���擾
                If .Cells(i, 2) = "subCategory" Then
                    cnt_sub = cnt_sub + 1   'subCategory�v�f�J�E���g�A�b�v
                    arr1(cnt_main, cnt_sub) = .Cells(i, 3)       'subCategory���z��Z�b�g
                    arr2(cnt_main, cnt_sub) = .Cells(i + 1, 3)   '�i�[�摜�t�@�C�������z��Z�b�g
                    arr3(cnt_main, cnt_sub) = .Cells(i + 2, 3)   '�摜�t�@�C�����Q�z��Z�b�g
                End If
                
            '�Q��ځumainCategory�v�v�f�ȍ~�͏������Ȃ�(=�J��Ԃ������𔲂���)
            Else
                Exit For
            End If
            
        Next i
    End With
      
    '�u�g�p�@��wk�V�[�g�v�E�E�E�g�p�@����(=�`�F�b�N�{�b�N�X�}�g���b�N�X���)
    With ThisWorkbook.Sheets("wk_cb")
    
        '�����l(���Z�b�g)
        cnt_main1_sub = cnt_sub                     '����mainCategory�v�f����subcategory����ޔ�
        cnt_main = 1                                'mainCategory�v�f��(���ɏ��񕪂͓ǂݍ��񂾏��)
        cnt_sub = 0                                 'subCategory�v�f��
        maxRow = .Cells(1048576, 2).End(xlUp).Row   'Master�f�[�^�ŏI�s�ԍ�
        
        'Master�f�[�^�Ɏg�p�@���񂪂Ȃ��ꍇ�A�������Ƃ΂�
        If maxRow < startRow Then
            'none
        
        'Master�f�[�^�Ɏg�p�@���񂪂���ꍇ
        Else
        
            'Master�f�[�^�̐擪�s�ԍ�����ŏI�s�ԍ��܂ŏ������J��Ԃ�
            For i = startRow To maxRow
            
                '�umainCategory�v���擾
                If .Cells(i, 2) = "mainCategory" Then
                    cnt_main = cnt_main + 1                 'mainCategory�v�f�J�E���g�A�b�v
                    arrMain(cnt_main) = .Cells(i, 3)        'mainCategory���z��Z�b�g
                    arrSFMode(cnt_main) = .Cells(i + 1, 3)  'subFolderMode���z��Z�b�g
                    cnt_sub = 0                             'subCategory�v�f��
                End If
                
                '�usubCategory�v���擾
                If .Cells(i, 2) = "subCategory" Then
                    cnt_sub = cnt_sub + 1                       'subCategory�v�f�J�E���g�A�b�v
                    arr1(cnt_main, cnt_sub) = .Cells(i, 3)      'subCategory���z��Z�b�g
                    arr2(cnt_main, cnt_sub) = .Cells(i + 1, 3)  '�i�[�摜�t�@�C�������z��Z�b�g
                    arr3(cnt_main, cnt_sub) = .Cells(i + 2, 3)  '�摜�t�@�C�����Q�z��Z�b�g
                End If
                
            Next i
        End If
    End With
        
    '�u�@��ԍ�wk�V�[�g�v
    With ThisWorkbook.Sheets("wk_Eno")
        
        '��L�z��������Ƃ�XML�^�O�����o�͂���
        'mainCategory�֘A���^�O�o��
        For i = 1 To cnt_main
            Set node(3) = node(2).appendChild(xmlDoc.createNode(NODE_ELEMENT, "dict", ""))
            Set node(4) = node(3).appendChild(xmlDoc.createNode(NODE_ELEMENT, "key", ""))
            node(4).Text = "items"
            Set node(4) = node(3).appendChild(xmlDoc.createNode(NODE_ELEMENT, "array", ""))
            
            'subCategory�֘A���^�O�o��
            For j = 1 To cnt_main1_sub
                Set node(5) = node(4).appendChild(xmlDoc.createNode(NODE_ELEMENT, "dict", ""))
                Set node(6) = node(5).appendChild(xmlDoc.createNode(NODE_ELEMENT, "key", ""))
                node(6).Text = "countStoredImages"
                Set node(6) = node(5).appendChild(xmlDoc.createNode(NODE_ELEMENT, "integer", ""))
                node(6).Text = arr2(i, j)   '�i�[�摜�t�@�C����
                Set node(6) = node(5).appendChild(xmlDoc.createNode(NODE_ELEMENT, "key", ""))
                node(6).Text = "images"
                Set node(6) = node(5).appendChild(xmlDoc.createNode(NODE_ELEMENT, "array", ""))
                
                '�摜�t�@�C���֘A���^�O�o��
                arr4 = Split(arr3(i, j), ",")
                For k = 0 To UBound(arr4)
                    If arr4(k) <> "" Then
                        Set node(7) = node(6).appendChild(xmlDoc.createNode(NODE_ELEMENT, "dict", ""))
                        Set node(8) = node(7).appendChild(xmlDoc.createNode(NODE_ELEMENT, "key", ""))
                        node(8).Text = "imageFile"
                        Set node(8) = node(7).appendChild(xmlDoc.createNode(NODE_ELEMENT, "string", ""))
                        node(8).Text = arr4(k)  '�摜�t�@�C����
                    End If
                Next k
                
                'subCategory�֘A���^�O�o��(�Â�)
                Set node(6) = node(5).appendChild(xmlDoc.createNode(NODE_ELEMENT, "key", ""))
                node(6).Text = "subCategory"
                Set node(6) = node(5).appendChild(xmlDoc.createNode(NODE_ELEMENT, "string", ""))
                node(6).Text = arr1(i, j)   '�T�u�J�e�S����
                
            Next j
            
            'mainCategory�֘A���^�O�o��(�Â�)
            Set node(4) = node(3).appendChild(xmlDoc.createNode(NODE_ELEMENT, "key", ""))
            node(4).Text = "mainCategory"
            Set node(4) = node(3).appendChild(xmlDoc.createNode(NODE_ELEMENT, "string", ""))
            node(4).Text = arrMain(i)   '���C���J�e�S����
            Set node(4) = node(3).appendChild(xmlDoc.createNode(NODE_ELEMENT, "key", ""))
            node(4).Text = "subFolderMode"
            Set node(4) = node(3).appendChild(xmlDoc.createNode(NODE_ELEMENT, "integer", ""))
            node(4).Text = arrSFMode(i) '�T�u�t�H���_���[�h
            
        Next i
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
Sub applySampleList()
    '**********************************
    '   Master(Excel)�X�V���f����
    '
    '   Created by: Takashi Kawamoto
    '   Created on: 2023/9/6
    '**********************************
    
    Dim shp, myShape
    Dim startRow, maxRow, cntRow, cntClm
    Dim cnt_main, cnt_sub
    Dim arr_main(1000) As Variant
    Dim arr1(1000, 1000) As Variant
    Dim arr2(1000, 1000) As Variant
    Dim arr3(1000, 1000) As Variant
    Dim arr4 As Variant
    Dim i, j, k, m
    Dim targetImage, imageName, img_size
    Dim cntColumn
    
    '*************************
    '�@��ʐ^��񏑂��o������
    '*************************

    '�S�Ẳ摜�t�@�C�����폜(��������)
    For Each shp In Sheets("SampleList").Shapes
        shp.Delete
    Next
    
    '��������
    startRow = 20
    cnt_main = 0
    cnt_sub = 0
    
    '�u�@��ԍ�wk�V�[�g�v
    With ThisWorkbook.Sheets("wk_Eno")
    
        maxRow = .Cells(1048576, 2).End(xlUp).Row   'Master�f�[�^�ŏI�s�ԍ�
        
        'Master�f�[�^�擪�s�ԍ�����ŏI�s�ԍ��܂ŏ�������
        For i = startRow To maxRow
        
            '�umainCategory�v���擾
            If .Cells(i, 2) = "mainCategory" Then
                cnt_main = cnt_main + 1             'maincategory�v�f���J�E���g�A�b�v
                arr_main(cnt_main) = .Cells(i, 3)   'mainCategory���z��Z�b�g
                cnt_sub = 0
            End If
            
            '�usubCategory�v���擾
            If .Cells(i, 2) = "subCategory" Then
                cnt_sub = cnt_sub + 1                       'subCategory�v�f���J�E���g�A�b�v
                arr1(cnt_main, cnt_sub) = .Cells(i, 3)      'subCategory���z��Z�b�g
                arr2(cnt_main, cnt_sub) = .Cells(i + 1, 3)  '�i�[�摜�t�@�C�������z��Z�b�g
                arr3(cnt_main, cnt_sub) = .Cells(i + 2, 3)   '�摜�t�@�C�����Q�z��Z�b�g
            End If
            
        Next i
    End With
    
    '�u�g�p�@��wk�V�[�g�v
    With ThisWorkbook.Sheets("wk_cb")
    
        maxRow = .Cells(1048576, 2).End(xlUp).Row   'Master���ŏI�s�ԍ�
        
        'Master�f�[�^�擪�s�ԍ�����ŏI�s�ԍ��܂ŏ�������
        For i = startRow To maxRow
            
            '�umainCategory�v���擾
            If .Cells(i, 2) = "mainCategory" Then
                cnt_main = cnt_main + 1             'maincategory�v�f���J�E���g�A�b�v
                arr_main(cnt_main) = .Cells(i, 3)   'mainCategory���z��Z�b�g
                cnt_sub = 0
            End If
            
            '�usubCategory�v���擾
            If .Cells(i, 2) = "subCategory" Then
                cnt_sub = cnt_sub + 1                       'subCategory�v�f���J�E���g�A�b�v
                arr1(cnt_main, cnt_sub) = .Cells(i, 3)      'subCategory���z��Z�b�g
                arr2(cnt_main, cnt_sub) = .Cells(i + 1, 3)  '�i�[�摜�t�@�C�������z��Z�b�g
                arr3(cnt_main, cnt_sub) = .Cells(i + 2, 3)   '�摜�t�@�C�����Q�z��Z�b�g
            End If
            
        Next i
    End With
    
    '�V�[�g�؂�ւ�
    ThisWorkbook.Sheets("SampleList").Select
    With ThisWorkbook.Sheets("SampleList")
    
        '�����l
        cntRow = 2
        
        '�o�̓G���A�N���A
        .Range(.Cells(2, 1), .Cells(1048576, 5)).Clear
        .Columns("N:XFD").Clear
        
        'mainCategory�P�Ԗڗv�f��subCategory�v�f�����������J��Ԃ�
        For i = 1 To UBound(arr1, 2)
        
            '�擪subCategory����f�[�^�̏ꍇ�A�������I������
            If arr1(1, i) = "" Then
                Exit For
            End If
            
            .Cells(cntRow, 1) = arr1(1, i)  'subCategory��(���)�˃V�[�g1��ڂɏ����o��
            
            '�Z�������ݒ�
            With .Cells(cntRow, 1)
                .VerticalAlignment = xlCenter
            End With
            
            '�摜�t�@�C�����Q��z��Ɋi�[
            arr4 = Split(arr3(1, i), ",")
            cntClm = 2
            
            '�摜�t�@�C��������������
            For j = 0 To UBound(arr4, 1)
                .Cells(cntRow, cntClm) = arr4(j)   '�摜�t�@�C�����˃V�[�g2��ڂ��珇���E�ɏ����o��
                
                '�Z�������ݒ�
                With .Cells(cntRow, cntClm)
                    .HorizontalAlignment = xlGeneral
                    .VerticalAlignment = xlBottom
                    .WrapText = False
                    .Orientation = 0
                    .AddIndent = False
                    .IndentLevel = 0
                    .ShrinkToFit = True
                    .ReadingOrder = xlContext
                    .MergeCells = False
                End With
                
                '�摜�t�@�C���p�X�擾
                imageName = .Cells(cntRow, cntClm)
                targetImage = Replace(ThisWorkbook.Sheets("wk_Eno").Cells(1, 3), "&img.plist", "") & "\" & imageName
                img_size = ThisWorkbook.Sheets("wk_Eno").Cells(16, 9)   '�C���[�W�k���T�C�Y
                
                '�摜�t�@�C��(�T���l�C��)�̃V�[�g�\��t���ʒu�����l��
                For k = 1 To cntClm - 1
                    .Columns(k).Hidden = True
                Next k
                
                '�摜�t�@�C��(�T���l�C��)�\��t��
                Set myShape = .Shapes.AddPicture( _
                              fileName:=targetImage, _
                              LinkToFile:=False, _
                              SaveWithDocument:=True, _
                              Left:=.Cells(cntRow, cntClm).Left, _
                              Top:=.Cells(cntRow, cntClm).Top, _
                              Width:=0, _
                              Height:=0)
                If myShape.Rotation = 270 Then
                    With myShape
                        .Rotation = 90
                    End With
                End If
                
                '�\�t�T���l�C���摜�̃T�C�Y�k�����e�ʈ��k
                With myShape
                    .ScaleHeight img_size, msoTrue
                    .ScaleWidth img_size, msoTrue
                    .Left = .Left + 1
                    .Select
                    Application.SendKeys "%s~"
                    Application.CommandBars.ExecuteMso "PicturesCompress"
                End With
                                
                '�摜�t�@�C��(�T���l�C��)�̃V�[�g�\��t���ʒu�����l��
                For k = 1 To cntClm - 1
                    .Columns(k).Hidden = False
                Next k
                
                '�\�t�T���l�C���摜�Ɍ��摜�ւ̃����N��ǉ�
                .Hyperlinks.Add Anchor:=myShape, Address:=targetImage
                .Hyperlinks.Add Anchor:=.Cells(cntRow, cntClm), Address:=targetImage, TextToDisplay:=imageName
                
                cntClm = cntClm + 1 '�����o����ԍ��J�E���g�A�b�v
            Next j
            cntRow = cntRow + 1 '�����o���s�ԍ��J�E���g�A�b�v
        Next i
    End With
    
    '*********************************************
    '�`�F�b�N�{�b�N�X�}�g���b�N�X��񏑂��o������
    '*********************************************
    
    '��������
    cntColumn = 14
    cntRow = 1
    
    'mainCategory�v�f����2�ȏ�̏ꍇ�A�������� (mainCategory�Q�Ԗڈȍ~�Ƀ`�F�b�N�{�b�N�X��񂪊i�[�����)
    If UBound(arr1, 1) >= 2 Then
    
        With ThisWorkbook.Sheets("SampleList")
        
            '�o�̓G���A�N���A
            .Range(.Columns(cntColumn), .Columns(16384)).Clear
    
            'mainCategory�̂Q�Ԗڂ���ŏI�v�f�܂ŏ�������
            For m = 2 To UBound(arr1, 1)
            
                'subCategory��񂪋�̏ꍇ�A�������I������
                If arr1(m, 1) = "" Then
                    Exit For
                End If
                
                .Cells(cntRow, cntColumn) = arr_main(m) 'mainCategory��(���)�˃V�[�g13��ڂ��珇���E�ɏ����o��
                cntRow = cntRow + 1 '�����o���s�ԍ��J�E���g�A�b�v
                
                'subCategory�̂P�Ԗڂ���ŏI�v�f�܂ŏ�������
                For i = 1 To UBound(arr1, 2)
                
                    'subCategory��񂪋�̏ꍇ�A�������I������
                    If arr1(m, i) = "" Then
                        Exit For
                    End If
                    
                    'subCategory��(���)�̐擪�������u*�v�̏ꍇ�A�u���v�������o��
                    If Left(arr1(m, i), 1) = "*" Then
                        .Cells(cntRow, cntColumn) = "��"
                        
                    'subCategory��(���)�̐擪�������u*�v�ȊO�̏ꍇ�A�u-�v�������o��
                    Else
                        .Cells(cntRow, cntColumn) = "-"
                    End If
                    
                    '�Z�������ݒ�
                    With .Cells(cntRow, cntColumn)
                        .HorizontalAlignment = xlCenter
                        .VerticalAlignment = xlCenter
                    End With
                    
                    cntRow = cntRow + 1 '�����o���s�ԍ��J�E���g�A�b�v
                Next i
                
                cntColumn = cntColumn + 1   '�����o����ԍ��J�E���g�A�b�v
                cntRow = 1                  '�����o���s�ԍ����Z�b�g
            Next m
        End With
    End If
    
    '�I������
    ThisWorkbook.Sheets("SampleList").Cells(1, 1).Select
    MsgBox ("Master�X�V����")
End Sub






