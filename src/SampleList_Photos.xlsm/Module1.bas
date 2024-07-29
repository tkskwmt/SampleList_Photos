Attribute VB_Name = "Module1"
Option Explicit
Sub createMasterData()
    '**********************************
    '   Masterデータ作成処理
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

    'tempフォルダ有無チェック
    If Dir("c:\temp", vbDirectory) = "" Then
        MkDir "c:\temp"
    End If
    
    'Masterデータフォルダ
    masterDir = ThisWorkbook.Path & "\Master"
    
    'Masterデータフォルダがない場合は新規作成する＆Master(Excel)内の業務番号をクリアする
    If Dir(masterDir, vbDirectory) = "" Then
        MkDir masterDir
        ThisWorkbook.Sheets("SampleList").Cells(1, 1).ClearContents
        
    'Masterデータフォルダが既に存在する場合は、確認メッセージを出して処理を中止する。(誤って初期化するのを防ぐため)
    Else
        MsgBox ("Masterフォルダが存在します。" & Chr(10) & "初期化したい場合は､Masterフォルダを削除してから再実行してください｡")
        Exit Sub
    End If
    
    '機器No入力
    strEqNo = InputBox("機器No？(例：E01-99,M01-99)(Max.333)", , "E01-99,M01-99")
    
    '半角/全角スペースを削除
    strEqNo = Replace(strEqNo, " ", "")
    strEqNo = Replace(strEqNo, "　", "")
    
    '未入力なら処理を中止する
    If strEqNo = "" Then
        MsgBox ("処理を中止します。(機器No未入力)")
        GoTo abort
    End If
    
    '機器Noを「SampleList」シートに書き出し
    eqNoClm = 7
    toClm = 13
    wtRow = 3
    With ThisWorkbook.Sheets("SampleList")
    
        '書き出しエリアクリア
        .Range(.Cells(2, eqNoClm - 1), .Cells(1048576, eqNoClm)).ClearContents
    
        arrEqNo = Split(strEqNo, ",")
        For i = 0 To UBound(arrEqNo)
            
            '入力値に「-」がない場合は処理を中止する
            If InStr(arrEqNo(i), "-") = 0 Then
                MsgBox ("処理を中止します。" & Chr(10) & "機器Noの開始番号と終了番号の間に「-」を追加してください。" & Chr(10) & "入力値：" & arrEqNo(i))
                GoTo abort
            End If
            
            '【特殊考慮】機器Noの接頭語に数字を入れたい場合は、数字入り接頭語を大カッコ[]でくくる
            If InStr(arrEqNo(i), "]") > 0 Then
                posNum = InStr(arrEqNo(i), "]") + 1
                If Mid(arrEqNo(i), posNum, 1) <> "0" Then
                    MsgBox ("処理を中止します。" & Chr(10) & "機器Noの開始番号は０埋めで指定してください。(例：E01, E001, H01, 等)" & Chr(10) & "入力値：" & arrEqNo(i))
                    GoTo abort
                End If
                
                '機器Noの接頭語を取得する
                strPre = Replace(Replace(Left(arrEqNo(i), posNum - 1), "[", ""), "]", "") '機器Noの接頭語
                
                '接頭語チェック
                If strPre = "" Then
                    MsgBox ("処理を中止します。(機器Noの接頭語が判別できません)" & Chr(10) & "入力値：" & arrEqNo(i))
                    GoTo abort
                End If
            Else
                '入力値(開始番号)を左から見て最初に「0」が見つかった位置の手前までを機器Noの接頭語(「E」等)と判別する
                strFromEqNo = Left(arrEqNo(i), InStr(arrEqNo(i), "-") - 1)
                posNum = InStr(strFromEqNo, "0")
                
                '入力値に「0」が見つからない場合、処理中止
                If posNum = 0 Then
                    MsgBox ("処理を中止します。" & Chr(10) & "機器Noの開始番号は０埋めで指定してください。(例：E01, E001, H01, 等)" & Chr(10) & "入力値：" & arrEqNo(i))
                    GoTo abort
                End If
                
                '機器Noの接頭語を取得する
                strPre = Left(arrEqNo(i), posNum - 1)   '機器Noの接頭語
            
                '接頭語チェック
                If strPre = "" Then
                    MsgBox ("処理を中止します。(機器Noの接頭語が判別できません)" & Chr(10) & "入力値：" & arrEqNo(i))
                    GoTo abort
                End If
                For k = 1 To Len(strPre)
                    If IsNumeric(Mid(strPre, k, 1)) Then
                        MsgBox ("処理を中止します。(機器Noの接頭語に数字は入れられません)" & Chr(10) & "接頭語：" & strPre & Chr(10) & "入力値：" & arrEqNo(i))
                        GoTo abort
                    End If
                Next k
            End If
            
            '機器Noの開始番号と終了番号を取得する
            strNum = Mid(arrEqNo(i), posNum)
            arrNum = Split(strNum, "-")
            fromNum = arrNum(0) '機器No-開始番号
            toNum = arrNum(1)   '機器No-終了番号
            toNum = Replace(toNum, strPre, "")  '機器Noの終了番号に接頭語が含まれる場合は接頭語を削除して数値化する
            
            '開始番号-終了番号チェック
            If IsNumeric(fromNum) = False Or IsNumeric(toNum) = False Then
                MsgBox ("処理を中止します。(機器Noの開始・終了番号が数値ではありません)" & Chr(10) & "接頭語：" & strPre & Chr(10) & "開始番号：" & fromNum & Chr(10) & "終了番号：" & toNum)
                GoTo abort
            End If
            If CInt(fromNum) > CInt(toNum) Then
                MsgBox ("処理を中止します。(機器Noの開始番号が終了番号より大きくなっています)" & Chr(10) & "接頭語：" & strPre & Chr(10) & "開始番号：" & fromNum & Chr(10) & "終了番号：" & toNum)
                GoTo abort
            End If
            '終了番号最大値チェック
            If toNum > 333 Then
                MsgBox ("処理を中止します。(機器Noの終了番号は333以下に設定してください)")
                GoTo abort
            End If
            'デバッグ用
            'MsgBox ("fromNum: " & fromNum & " toNum: " & toNum)
            
            '機器Noの接頭語の切り替わり位置をマーキングする
            .Cells(wtRow, eqNoClm - 1) = strPre
            With .Cells(wtRow, eqNoClm - 1)
                .VerticalAlignment = xlCenter
            End With
            
            '機器Noの開始番号から終了番号まで処理を繰り返す
            For j = CInt(fromNum) To CInt(toNum)
            
                '数値桁数チェック
                If Len(toNum) >= 4 Then
                    MsgBox ("処理を終了します。(機器Noの数値は最大3桁まで)" & Chr(10) & "入力値：" & toNum)
                    GoTo abort
                End If
                
                '終了番号の桁数により番号のゼロ埋めをする
                Select Case Len(toNum)
                Case 1
                    .Cells(wtRow, eqNoClm) = strPre & Format(j, "00")
                Case 2
                    .Cells(wtRow, eqNoClm) = strPre & Format(j, "00")
                Case 3
                    .Cells(wtRow, eqNoClm) = strPre & Format(j, "000")
                End Select
                
                'セル書式設定
                With .Range(.Cells(wtRow, eqNoClm), .Cells(wtRow, toClm))
                    .VerticalAlignment = xlCenter
                End With
                
                '書き出し行番号インクリメント
                wtRow = wtRow + 1
            Next j
        Next i
    End With
    
    'PLIST新規作成処理
    Call createPlist(eqNoClm)
    
    'ZIPファイル新規作成処理
    Call createZip
    
    'Master(Excel)保存
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
            Name oldFilePath As ThisWorkbook.Path & "\old\【旧】" & oldFileName
        End If
        MsgBox ("Master(Excel)ファイルが読み取り専用のため別名で保存しました" & Chr(10) & newFileName)
    Else
        ThisWorkbook.Save
    End If
    
    '終了処理
    MsgBox ("Masterデータ作成完了")
    Exit Sub
    
abort:
        'Masterデータフォルダ削除
        If Dir(masterDir, vbDirectory) <> "" Then
            With CreateObject("Scripting.FileSystemObject")
                .DeleteFolder masterDir
            End With
        End If
    
End Sub
Sub createPlist(eqNoClm)
    '**********************************
    '   PLIST新規作成処理
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
    Dim i, j        As Integer
    Dim tempFile
    Dim startRow, maxRow, fromRow, toRow
    Dim mainCategoryName
    
    With ThisWorkbook.Sheets("SampleList")
    
        tempFile = "c:\\temp\\temp.plist"   '一時ファイル
        fileName = ThisWorkbook.Path & "\Master\SampleList.plist" 'new plist(=Masterデータ)⇒Master(Excel)の同一階層の「Master」フォルダに出力される
                
        'XMLファイル出力準備
        Set xmlDoc = New MSXML2.DOMDocument60
        Set xmlPI = xmlDoc.appendChild(xmlDoc.createProcessingInstruction("xml", "version=""1.0"" encoding=""UTF-8"""))
        Set xmlPI = xmlDoc.appendChild(xmlDoc.createProcessingInstruction("DOCTYPE", ""))
        Set node(1) = xmlDoc.appendChild(xmlDoc.createNode(NODE_ELEMENT, "plist", ""))
        Set node(2) = node(1).appendChild(xmlDoc.createNode(NODE_ELEMENT, "array", ""))
        
        '初期値
        startRow = 3                                     '先頭行番号
        maxRow = .Cells(1048576, eqNoClm).End(xlUp).Row  '最終行番号
        
        '上記情報をもとにXMLタグ情報を出力する
        Select Case ThisWorkbook.Sheets("Menu").Cells(1, 7)
        Case "単一"
            '*** 単一メインカテゴリ形式 ***
            mainCategoryName = "@"
            'mainCategory関連情報タグ出力1
            Set node(3) = node(2).appendChild(xmlDoc.createNode(NODE_ELEMENT, "dict", ""))
            Set node(4) = node(3).appendChild(xmlDoc.createNode(NODE_ELEMENT, "key", ""))
            node(4).Text = "items"
            Set node(4) = node(3).appendChild(xmlDoc.createNode(NODE_ELEMENT, "array", ""))
            
            'subCategory関連情報タグ出力
            For j = startRow To maxRow
                Set node(5) = node(4).appendChild(xmlDoc.createNode(NODE_ELEMENT, "dict", ""))
                Set node(6) = node(5).appendChild(xmlDoc.createNode(NODE_ELEMENT, "key", ""))
                node(6).Text = "countStoredImages"
                Set node(6) = node(5).appendChild(xmlDoc.createNode(NODE_ELEMENT, "integer", ""))
                node(6).Text = "0"  'デフォルト値
                Set node(6) = node(5).appendChild(xmlDoc.createNode(NODE_ELEMENT, "key", ""))
                node(6).Text = "images"
                Set node(6) = node(5).appendChild(xmlDoc.createNode(NODE_ELEMENT, "array", ""))
                Set node(6) = node(5).appendChild(xmlDoc.createNode(NODE_ELEMENT, "key", ""))
                node(6).Text = "subCategory"
                Set node(6) = node(5).appendChild(xmlDoc.createNode(NODE_ELEMENT, "string", ""))
                node(6).Text = .Cells(j, eqNoClm) & ":=-,-,-"   'サブカテゴリ名
            Next j
        
            'mainCategory関連情報タグ出力2
            Set node(4) = node(3).appendChild(xmlDoc.createNode(NODE_ELEMENT, "key", ""))
            node(4).Text = "mainCategory"
            Set node(4) = node(3).appendChild(xmlDoc.createNode(NODE_ELEMENT, "string", ""))
            node(4).Text = mainCategoryName & ":=,," 'メインカテゴリ名
            Set node(4) = node(3).appendChild(xmlDoc.createNode(NODE_ELEMENT, "key", ""))
            node(4).Text = "subFolderMode"
            Set node(4) = node(3).appendChild(xmlDoc.createNode(NODE_ELEMENT, "integer", ""))
            node(4).Text = "0"  'デフォルト値
                
        Case "複数"
            '*** 複数メインカテゴリ形式 ***
            For i = startRow To maxRow
                If .Cells(i, eqNoClm - 1) <> "" Then
                    mainCategoryName = "@-" & .Cells(i, eqNoClm - 1)
                    fromRow = i
                    toRow = .Cells(i, eqNoClm - 1).End(xlDown).Row - 1
                    If toRow > maxRow Then
                        toRow = maxRow
                    End If
    
                    'mainCategory関連情報タグ出力1
                    Set node(3) = node(2).appendChild(xmlDoc.createNode(NODE_ELEMENT, "dict", ""))
                    Set node(4) = node(3).appendChild(xmlDoc.createNode(NODE_ELEMENT, "key", ""))
                    node(4).Text = "items"
                    Set node(4) = node(3).appendChild(xmlDoc.createNode(NODE_ELEMENT, "array", ""))
    
                    'subCategory関連情報タグ出力
                    For j = fromRow To toRow
                        Set node(5) = node(4).appendChild(xmlDoc.createNode(NODE_ELEMENT, "dict", ""))
                        Set node(6) = node(5).appendChild(xmlDoc.createNode(NODE_ELEMENT, "key", ""))
                        node(6).Text = "countStoredImages"
                        Set node(6) = node(5).appendChild(xmlDoc.createNode(NODE_ELEMENT, "integer", ""))
                        node(6).Text = "0"  'デフォルト値
                        Set node(6) = node(5).appendChild(xmlDoc.createNode(NODE_ELEMENT, "key", ""))
                        node(6).Text = "images"
                        Set node(6) = node(5).appendChild(xmlDoc.createNode(NODE_ELEMENT, "array", ""))
                        Set node(6) = node(5).appendChild(xmlDoc.createNode(NODE_ELEMENT, "key", ""))
                        node(6).Text = "subCategory"
                        Set node(6) = node(5).appendChild(xmlDoc.createNode(NODE_ELEMENT, "string", ""))
                        node(6).Text = .Cells(j, eqNoClm) & ":=-,-,-"   'サブカテゴリ名
                    Next j
    
                    'mainCategory関連情報タグ出力2
                    Set node(4) = node(3).appendChild(xmlDoc.createNode(NODE_ELEMENT, "key", ""))
                    node(4).Text = "mainCategory"
                    Set node(4) = node(3).appendChild(xmlDoc.createNode(NODE_ELEMENT, "string", ""))
                    node(4).Text = mainCategoryName & ":=,," 'メインカテゴリ名
                    Set node(4) = node(3).appendChild(xmlDoc.createNode(NODE_ELEMENT, "key", ""))
                    node(4).Text = "subFolderMode"
                    Set node(4) = node(3).appendChild(xmlDoc.createNode(NODE_ELEMENT, "integer", ""))
                    node(4).Text = "0"  'デフォルト値
                End If
            Next i
        End Select
    End With
    
    xmlDoc.Save (tempFile)  '一時ファイル保存
    
    Dim inputSt As New ADODB.stream
    Dim outputSt As New ADODB.stream
    Dim outputSt2 As New ADODB.stream
    
    With inputSt
        .Charset = "UTF-8"
        .Open
        .LoadFromFile (tempFile)
        fileData = .ReadText
        str = "<!DOCTYPE plist PUBLIC ""-//Apple//DTD PLIST 1.0//EN"" ""http://www.apple.com/DTDs/PropertyList-1.0.dtd"">"
        find = Array("<?DOCTYPE?>", "<plist>", "><")
        rep = Array(str, "<plist version=""1.0"">", ">" & vbLf & "<")
        For i = 0 To UBound(find)
            fileData = Replace(fileData, find(i), rep(i))
        Next i
        .Close
    End With
    With outputSt
        .Charset = "UTF-8"
        .Open
        .WriteText fileData
        .Position = 3
        With outputSt2
            .Type = adTypeBinary
            .Open
            outputSt.CopyTo outputSt2
            .SaveToFile (fileName), 2
            .Close
        End With
        .Close
    End With
    
    If Dir(tempFile) <> "" Then
        Kill tempFile   '一時ファイル削除
    End If
    
End Sub
Sub createZip()
    '**********************************
    '   ZIPファイル新規作成処理
    '
    '   Created by: Takashi Kawamoto
    '   Created on: 2023/9/8
    '**********************************
    
    Dim masterDir
    Dim fileName
    Dim toFolder
    Dim zipSrcFolder

    'Masterデータ(写真)フォルダ
    masterDir = ThisWorkbook.Path & "\Master\SampleList"
    
    'Masterデータフォルダがない場合は新規作成する
    If Dir(masterDir, vbDirectory) = "" Then
        MkDir masterDir
    End If
    
    '操作説明画像作成
    fileName = masterDir & "\@readme.jpg"
    
    'JPGファイル新規作成処理
    Call createJPG(fileName)

    'ZIP圧縮ファイルの保存先フォルダ(＝Masterデータフォルダ「SampleList\」の一つ上の階層フォルダ)を指定する
    toFolder = Mid(masterDir, 1, InStrRev(masterDir, "\") - 1)
    
    'ZIP圧縮したいフォルダ(=Masterデータフォルダ)を指定する
    zipSrcFolder = masterDir
    
    'ZIP圧縮したいフォルダが存在する場合のみ、ZIP圧縮を行う
    If Dir(zipSrcFolder, vbDirectory) <> "" Then
    
        'ZIP圧縮処理
        Call ZipFileOrFolder2(zipSrcFolder)
    End If

End Sub
Sub createJPG(fName)
    '**********************************
    '   JPGファイル新規作成処理
    '
    '   Created by: Takashi Kawamoto
    '   Created on: 2023/9/8
    '**********************************

    Dim rg
    Dim cht As Chart
    Dim fileSize
    
    '操作説明エリアコピー
    With ThisWorkbook.Sheets("Menu")
        Set rg = .Range(.Cells(50, 1), .Cells(100, 26))
    End With
    rg.CopyPicture
    
    '一時データ作成＆画像貼り付け＆JPGファイルエクスポート
    Set cht = ThisWorkbook.Sheets("Menu").ChartObjects.Add(0, 0, rg.Width, rg.Height).Chart
    cht.Export fileName:=fName, filtername:="JPG"
    fileSize = FileLen(fName)
    
    Do Until FileLen(fName) > fileSize
        cht.Paste
        cht.Export fileName:=fName, filtername:="JPG"
        DoEvents
    Loop
    
    '一時データ削除
    cht.Parent.Delete

End Sub
Sub editSampleID()
    '**********************************
    '   サンプル業務番号設定・編集
    '
    '   Created by: Takashi Kawamoto
    '   Created on: 2023/9/14
    '**********************************
    Dim strSID
    Dim tempFile
    Dim plistPath_master
    Dim find
    Dim rep
    Dim fileData
    Dim i
    Dim wb As Workbook
    Dim oldFileName
    Dim oldFilePath
    Dim newFileName
    Dim newFilePath

    'サンプル業務番号入力(初回のみ)
    With ThisWorkbook.Sheets("SampleList")
        If .Cells(1, 1) = "" Then
             strSID = InputBox("サンプル業務番号？", , "EMCxx-xxxx")
        Else
             strSID = InputBox("サンプル業務番号を変更しますか？", , .Cells(1, 1))
        End If
        If strSID <> "" Then
            .Cells(1, 1) = strSID
        Else
            Exit Sub
        End If
    End With
    
    '【PLIST名】Masterデータ: SampleList.plist
    plistPath_master = ThisWorkbook.Path & "\Master\SampleList.plist"
    
    'PLIST-Masterデータ内のmainCategory名を「サンプル業務番号」で上書きする
    tempFile = "c:\\temp\\temp.plist"   '一時ファイル
    FileCopy plistPath_master, tempFile
    
    Dim inputSt As New ADODB.stream
    Dim outputSt As New ADODB.stream
    Dim outputSt2 As New ADODB.stream
    Dim reg As New RegExp
    
    With inputSt
        .Charset = "UTF-8"
        .Open
        .LoadFromFile (tempFile)
        fileData = .ReadText
        find = Array("<string>@")
        With reg
            .Pattern = "<string>EMC..-....-"
            .IgnoreCase = False
            .Global = True
        End With
        rep = Array("<string>" & strSID)
        For i = 0 To UBound(find)
            fileData = Replace(fileData, find(i), rep(i))
        Next i
        fileData = reg.Replace(fileData, "<string>" & strSID & "-")
        .Close
    End With
    With outputSt
        .Charset = "UTF-8"
        .Open
        .WriteText fileData
        .Position = 3
        With outputSt2
            .Type = adTypeBinary
            .Open
            outputSt.CopyTo outputSt2
            .SaveToFile (plistPath_master), 2
            .Close
        End With
        .Close
    End With
    
    If Dir(tempFile) <> "" Then
        Kill tempFile   '一時ファイル削除
    End If
    
    'Master(Excel)保存
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
            Name oldFilePath As ThisWorkbook.Path & "\old\【旧】" & oldFileName
        End If
        MsgBox ("Master(Excel)ファイルが読み取り専用のため別名で保存しました" & Chr(10) & newFileName)
    Else
        ThisWorkbook.Save
    End If
    
    '処理終了
    MsgBox ("サンプル業務番号反映完了")
End Sub
Sub createCarryOutData()
    '**********************************
    '   ハンディ持出データ作成
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
    
    'サンプル業務番号入力(初回のみ)
    With ThisWorkbook.Sheets("SampleList")
        If .Cells(1, 1) = "" Then
            Call editSampleID
        End If
        strSID = .Cells(1, 1)
    End With
    
    '日付入力データ取得
    strDate = InputBox("日付yymmdd？", , Format(Date, "yymmdd"))
    If strDate = "" Then
        Exit Sub
    End If
    
    '設備入力データ取得
    strTestRoomNo = InputBox("設備名？", , "ALCx")
    If strTestRoomNo = "" Then
        Exit Sub
    End If
    
    '持出データ名：SampleList_「日付」_「設備名」.plist
    fileName = ThisWorkbook.Sheets("Menu").Cells(1, 3) & "_" & strDate & "_" & strTestRoomNo
    
    '【PLIST名】Masterデータ: SampleList.plist
    plistPath_target = ThisWorkbook.Path & "\" & fileName & ".plist"
    plistPath_master = ThisWorkbook.Path & "\Master\SampleList.plist"
    
    '【ZIPファイル名】Masterデータ: SampleLost.zip
    zipPath_target = ThisWorkbook.Path & "\" & fileName & ".zip"
    zipPath_master = ThisWorkbook.Path & "\Master\SampleList.zip"
    
    '【ZIP対象フォルダ名】Masterデータ: SampleLost\
    folderPath_target = ThisWorkbook.Path & "\" & fileName
    folderPath_master = ThisWorkbook.Path & "\Master\SampleList\"
    folderPath_master2 = ThisWorkbook.Path & "\Master\SampleList"
    
    '【追加処理】PLIST-Masterデータ内のmainCategory名を「サンプル業務番号」に置き換える
    tempFile = "c:\\temp\\temp.plist"   '一時ファイル
    FileCopy plistPath_master, tempFile
    
    Dim inputSt As New ADODB.stream
    Dim outputSt As New ADODB.stream
    Dim outputSt2 As New ADODB.stream
    
    With inputSt
        .Charset = "UTF-8"
        .Open
        .LoadFromFile (tempFile)
        fileData = .ReadText
        find = Array("<string>SampleList</string>")
        rep = Array("<string>" & strSID & "</string>")
        For i = 0 To UBound(find)
            fileData = Replace(fileData, find(i), rep(i))
        Next i
        .Close
    End With
    With outputSt
        .Charset = "UTF-8"
        .Open
        .WriteText fileData
        .Position = 3
        With outputSt2
            .Type = adTypeBinary
            .Open
            outputSt.CopyTo outputSt2
            .SaveToFile (plistPath_master), 2
            .Close
        End With
        .Close
    End With
    
    If Dir(tempFile) <> "" Then
        Kill tempFile   '一時ファイル削除
    End If
    
    'zipファイルがある場合、「zip」Masterデータと「.plist」Masterデータをコピーして持出データを作成する
    If Dir(zipPath_master) <> "" Then
   
        '既存ファイルがない場合
        If Dir(zipPath_target) = "" And Dir(plistPath_target) = "" Then
            
            '「.plist」をコピー
            FileCopy plistPath_master, plistPath_target
            
            'zipファイル解凍処理
            Call unzipFile(plistPath_master)
            
            '解凍フォルダリネーム & zip対象フォルダ圧縮
            If Dir(folderPath_target, vbDirectory) <> "" Then
                With CreateObject("Scripting.FileSystemObject")
                    .DeleteFolder folderPath_target
                End With
            End If
            
            'Targetフォルダがない場合は新規作成する
            If Dir(folderPath_target, vbDirectory) = "" Then
                MkDir folderPath_target
            End If
            Set FSO = CreateObject("Scripting.FileSystemObject")
            FSO.CopyFolder folderPath_master2, folderPath_target
            Set FSO = Nothing
            
            'zip圧縮処理
            Call ZipFileOrFolder(folderPath_target)
            
            '解凍フォルダ削除(フォルダが存在する場合のみ)
            If Dir(folderPath_target, vbDirectory) <> "" Then
                With CreateObject("Scripting.FileSystemObject")
                    .DeleteFolder folderPath_target
                End With
            End If
        
        '既存ファイルがある場合
        Else
        
            '確認メッセージ表示
            strYN = MsgBox("以下のファイルを上書きしますか？" & Chr(10) & plistPath_target & Chr(10) & zipPath_target, vbYesNo)
            
            '「Yes」の場合
            If strYN = vbYes Then
            
                '「.plist」をコピー
                FileCopy plistPath_master, plistPath_target
                
                'zipファイル解凍処理
                Call unzipFile(plistPath_master)
                
                '解凍フォルダリネーム & zip対象フォルダ圧縮
                If Dir(folderPath_target, vbDirectory) <> "" Then
                    With CreateObject("Scripting.FileSystemObject")
                        .DeleteFolder folderPath_target
                    End With
                End If
                
                'Targetフォルダがない場合は新規作成する
                If Dir(folderPath_target, vbDirectory) = "" Then
                    MkDir folderPath_target
                End If
                
                Set FSO = CreateObject("Scripting.FileSystemObject")
                FSO.CopyFolder folderPath_master2, folderPath_target
                Set FSO = Nothing
                
                'zip圧縮処理
                Call ZipFileOrFolder(folderPath_target)
                
                '解凍フォルダ削除(フォルダが存在する場合のみ)
                If Dir(folderPath_target, vbDirectory) <> "" Then
                    With CreateObject("Scripting.FileSystemObject")
                        .DeleteFolder folderPath_target
                    End With
                End If
                
            '「No」の場合
            Else
                MsgBox ("処理を中止します")
                Exit Sub
            End If
            
        End If
        
        '持出データのチェックボックス情報を指定試験項目のみに更新する
        With ThisWorkbook.Sheets("wk_Eno")
            .Cells(1, 3) = plistPath_target  '持出データのフォルダパスを指定
        End With
        
        'PLISTデータ読込処理
        Call loadPlist(20, 1)
        
    'zipファイルがない場合、「.plist」Masterデータをコピーして持出データを作成する
    Else
        FileCopy plistPath_master, plistPath_target
    End If
    
    'Master(Excel)保存
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
            Name oldFilePath As ThisWorkbook.Path & "\old\【旧】" & oldFileName
        End If
        MsgBox ("Master(Excel)ファイルが読み取り専用のため別名で保存しました" & Chr(10) & newFileName)
    Else
        ThisWorkbook.Save
    End If

    '終了処理
    MsgBox ("持出データ出力完了")
End Sub
Sub applyCarryInData()
    '**********************************
    '   ハンディ持込データ処理
    '
    '   Created by: Takashi Kawamoto
    '   Created on: 2023/9/6
    '**********************************
    
    Dim startRow
    Dim startColumn
    Dim plistPath_target
    Dim plistPath_master
    Dim zipPath_target
    Dim folderPath_target
    Dim folderPath_master
    Dim isMaster
    Dim res
    Dim wb As Workbook
    Dim oldFileName, newFileName
    Dim oldFilePath, newFilePath
    Dim carryInFileName
    
    plistPath_master = ThisWorkbook.Path & "\Master\SampleList.plist"         '初回PLIST-Masterデータ(.plist)
    
    'PLIST-持込データ読込処理
    startRow = 20
    startColumn = 5
    isMaster = False
    
    '指示メッセージ表示
    MsgBox ("持込データを指定してください")
    
    'ファイル選択ダイアログ表示
    Call selectFile(startRow, startColumn, isMaster)
    
    '選択ファイルがない場合、処理を終了する
    If ThisWorkbook.Sheets("wk_Eno").Cells(1, startColumn + 2) = "" Then
        Exit Sub
    End If
    
    '指定した持込データがMaster(Excel)ファイルと同一フォルダ内に存在しない場合、処理を終了する
    If Left(ThisWorkbook.Sheets("wk_Eno").Cells(1, startColumn + 2), InStrRev(ThisWorkbook.Sheets("wk_Eno").Cells(1, startColumn + 2), "\") - 1) <> ThisWorkbook.Path Then
        MsgBox ("持込データはMaster(Excel)ファイルと同じフォルダ内のものを指定してください" & Chr(10) & "Master(Excel)ファイル場所: " & ThisWorkbook.Path)
        Exit Sub
    End If
    
    'PLIST-持込データ読込処理
    Call loadPlist(startRow, startColumn)
    
    '【追加】PLIST-持込データ-サンプル業務番号チェック
    If InStr(ThisWorkbook.Sheets("wk_Eno").Cells(startRow, 7), ThisWorkbook.Sheets("SampleList").Cells(1, 1)) = 0 Then
        MsgBox ("持込データのサンプル業務番号が一致しません。処理を中止します。")
        Exit Sub
    End If
    
    'PLIST-持込データ-管理種類チェック
    carryInFileName = Mid(ThisWorkbook.Sheets("wk_Eno").Cells(1, startColumn + 2), InStrRev(ThisWorkbook.Sheets("wk_Eno").Cells(1, startColumn + 2), "\") + 1)
    If InStr(ThisWorkbook.Sheets("wk_Eno").Cells(1, startColumn + 2), ThisWorkbook.Sheets("Menu").Cells(1, 3)) = 0 Then
        MsgBox ("持込データの管理種類(InOutMgr/EqpMgr)が一致しません。処理を中止します。" & Chr(10) & _
        "持込データ: " & Left(carryInFileName, InStr(carryInFileName, "Mgr_") + 2) & Chr(10) & _
        "Master: " & ThisWorkbook.Sheets("Menu").Cells(1, 3))
        Exit Sub
    End If
    
    'Masterデータ読込
    ThisWorkbook.Sheets("wk_Eno").Cells(1, 3) = plistPath_master
        
    'PLIST-Masterデータ読込処理
    startRow = 20
    startColumn = 1
    Call loadPlist(startRow, startColumn)
    
    'ZIP-Masterデータ解凍処理
    Call unzipFileMaster
    
    'PLIST-Master-持込データ比較処理
    Call comparePlist
    
    'ZIP-持込データ解凍処理
    Call unzipFileUpdated
    
    'PLIST仮マージ処理
    Call mergePlist
    
    'PLIST＆ZIP更新反映処理
    Call applyPlistAndZip

    'Master(Excel)更新反映処理
    Call applySampleList
       
    '持込データ解凍フォルダ削除(フォルダが存在する場合のみ)
    folderPath_target = Replace(ThisWorkbook.Sheets("wk_Eno").Cells(1, 7), ".plist", "")
    folderPath_master = ThisWorkbook.Path & "\Master\SampleList"
    
    '持込データ名がMasterデータ名と異なる場合のみ処理する
    If folderPath_target <> folderPath_master Then
        If Dir(folderPath_target, vbDirectory) <> "" Then
            With CreateObject("Scripting.FileSystemObject")
                .DeleteFolder folderPath_target
            End With
        End If
    End If
    
    '「SampleList」フォルダは、Master(Excel)内の各サムネイル写真にそれぞれリンクされた元写真が保存されているため削除しない
'    If Dir(folderPath_master, vbDirectory) <> "" Then
'        With CreateObject("Scripting.FileSystemObject")
'            .DeleteFolder folderPath_master
'        End With
'    End If

    '持込データ削除(ファイルが存在する場合のみ)
    plistPath_target = ThisWorkbook.Sheets("wk_Eno").Cells(1, 7)
    zipPath_target = Replace(ThisWorkbook.Sheets("wk_Eno").Cells(1, 7), ".plist", ".zip")
    
    '持込データ名がMasterデータ名と異なる場合のみ処理する
    If plistPath_target <> plistPath_master Then
    
        '確認メッセージ表示
        res = MsgBox("持込データを削除しますか？" & Chr(10) & plistPath_target & Chr(10) & zipPath_target, vbYesNo)
        
        '「Yes」の場合
        If res = vbYes Then
            If Dir(plistPath_target) <> "" Then
                Kill plistPath_target    '.plist
            End If
            If Dir(zipPath_target) <> "" Then
                Kill zipPath_target      'zip
            End If
        End If
    End If
    
    'Master(Excel)保存
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
            Name oldFilePath As ThisWorkbook.Path & "\old\【旧】" & oldFileName
        End If
        MsgBox ("Master(Excel)ファイルが読み取り専用のため別名で保存しました" & Chr(10) & newFileName)
    Else
        ThisWorkbook.Save
    End If
    
    '終了処理
    MsgBox ("持込データ処理完了")
End Sub



